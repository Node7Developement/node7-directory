(() => {
    'use strict';

    const state = {
        open: false,
        payload: {},
        categories: [],
        entries: [],
        categoryIndex: 0,
        entryIndex: 0,
        lastMoveSound: 0
    };

    const root = document.getElementById('directory');
    const els = {
        date: document.getElementById('dateText'),
        time: document.getElementById('timeText'),
        title: document.getElementById('directoryTitle'),
        subtitle: document.getElementById('directorySubtitle'),
        playerName: document.getElementById('playerName'),
        playerJob: document.getElementById('playerJob'),
        bank: document.getElementById('bankAmount'),
        gold: document.getElementById('goldAmount'),
        cash: document.getElementById('cashAmount'),
        categories: document.getElementById('categoryList'),
        categoryIndex: document.getElementById('categoryIndex'),
        categoryTotal: document.getElementById('categoryTotal'),
        categoryLabel: document.getElementById('categoryLabel'),
        entryCount: document.getElementById('entryCount'),
        entries: document.getElementById('entryList'),
        art: document.getElementById('detailArt'),
        monogram: document.getElementById('entryMonogram'),
        record: document.getElementById('entryRecord'),
        kicker: document.getElementById('entryKicker'),
        location: document.getElementById('entryLocation'),
        detailSection: document.getElementById('detailSection'),
        detailPosition: document.getElementById('detailPosition'),
        entryTitle: document.getElementById('entryTitle'),
        description: document.getElementById('entryDescription'),
        details: document.getElementById('entryDetails'),
        actions: document.getElementById('actionList'),
        footer: document.getElementById('footerBrand')
    };

    const sounds = {
        open: document.getElementById('soundOpen'),
        move: document.getElementById('soundMove'),
        categoryLeft: document.getElementById('soundCategoryLeft'),
        categoryRight: document.getElementById('soundCategoryRight'),
        select: document.getElementById('soundSelect'),
        close: document.getElementById('soundClose')
    };

    function playSound(name, volume = 0.2) {
        const source = sounds[name];
        if (!source) return;

        if (name === 'move') {
            const now = performance.now();
            if (now - state.lastMoveSound < 55) return;
            state.lastMoveSound = now;
        }

        try {
            const sound = source.cloneNode(true);
            sound.volume = volume;
            sound.play().catch(() => {});
            sound.addEventListener('ended', () => sound.remove(), { once: true });
        } catch (_) {}
    }

    function post(name, data = {}) {
        return fetch(`https://${GetParentResourceName()}/${name}`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json; charset=UTF-8' },
            body: JSON.stringify(data)
        }).then(response => response.json()).catch(() => ({ ok: false }));
    }

    function money(value, decimals = 0) {
        return Number(value || 0).toLocaleString('en-US', {
            minimumFractionDigits: decimals,
            maximumFractionDigits: decimals
        });
    }

    function updateClock() {
        const now = new Date();
        els.date.textContent = now.toLocaleDateString('en-US', { weekday: 'long' });
        els.time.textContent = now.toLocaleTimeString('en-US', { hour: 'numeric', minute: '2-digit' });
    }

    function normalize(payload) {
        const categories = Array.isArray(payload?.categories) ? payload.categories.slice() : [];
        const entries = Array.isArray(payload?.entries) ? payload.entries.slice() : [];

        categories.sort((a, b) => (a.order ?? 999) - (b.order ?? 999) || String(a.label).localeCompare(String(b.label)));
        entries.sort((a, b) => (a.order ?? 999) - (b.order ?? 999) || String(a.label).localeCompare(String(b.label)));

        return { categories, entries };
    }

    function entriesForCategory(category) {
        if (!category) return [];

        if (category.id === 'featured') {
            const featured = state.entries.filter(entry => entry.featured === true);
            return featured.length ? featured : state.entries.slice(0, 8);
        }

        return state.entries.filter(entry => entry.category === category.id);
    }

    function selectedCategory() {
        return state.categories[state.categoryIndex] || state.categories[0];
    }

    function selectedEntry() {
        const entries = entriesForCategory(selectedCategory());
        return entries[state.entryIndex] || entries[0];
    }

    function monogram(entry) {
        if (!entry) return 'N7';
        return String(entry.label || 'N7')
            .split(/\s+/)
            .filter(Boolean)
            .slice(0, 2)
            .map(word => word[0])
            .join('')
            .toUpperCase();
    }

    function recordCode(entry) {
        if (!entry?.id) return 'DIRECTORY RECORD';
        const compact = String(entry.id).replace(/[^a-z0-9]/gi, '').toUpperCase().slice(0, 12);
        return `N7 · ${compact || 'DIRECTORY'}`;
    }

    function renderPlayer() {
        const player = state.payload?.player || {};
        const job = player.job || {};
        const moneyData = player.money || {};

        els.playerName.textContent = player.name || 'Unknown';
        els.playerJob.textContent = `${job.label || 'Civilian'} · ${job.grade || 'Freelancer'}${job.onduty ? ' · On Duty' : ''}`;
        els.bank.textContent = money(moneyData.bank, 0);
        els.gold.textContent = money(moneyData.gold, 2);
        els.cash.textContent = money(moneyData.cash, 2);
    }

    function setCategory(index, withSound = true, direction = null) {
        if (!state.categories.length) return;

        const total = state.categories.length;
        const previousIndex = state.categoryIndex;
        const nextIndex = (index + total) % total;

        if (nextIndex === previousIndex) return;

        if (!direction) {
            const forwardDistance = (nextIndex - previousIndex + total) % total;
            const backwardDistance = (previousIndex - nextIndex + total) % total;
            direction = forwardDistance <= backwardDistance ? 'right' : 'left';
        }

        state.categoryIndex = nextIndex;
        state.entryIndex = 0;

        if (withSound) {
            // Play the local cue immediately. Native frontend sound calls can succeed
            // without producing audio on some RedM builds, so they are never the only cue.
            const categorySound = state.payload?.sound || {};
            if (categorySound.categoryEnabled !== false) {
                const volume = Math.max(0, Math.min(1, Number(categorySound.categoryVolume ?? 0.42)));
                playSound(direction === 'left' ? 'categoryLeft' : 'categoryRight', volume);
            }
            post('categorySound', { direction });
        }

        render();
    }

    function setEntry(index, withSound = true) {
        const entries = entriesForCategory(selectedCategory());
        if (!entries.length) return;
        state.entryIndex = (index + entries.length) % entries.length;
        if (withSound) playSound('move', 0.12);
        renderEntries();
        renderDetail();
    }

    function renderCategories() {
        els.categories.replaceChildren();

        state.categories.forEach((category, index) => {
            const button = document.createElement('button');
            button.type = 'button';
            button.className = `category-button${index === state.categoryIndex ? ' active' : ''}`;
            button.textContent = category.label;
            button.addEventListener('click', () => setCategory(index));
            els.categories.appendChild(button);
        });

        const category = selectedCategory();
        els.categoryIndex.textContent = String(state.categoryIndex + 1).padStart(2, '0');
        els.categoryTotal.textContent = String(Math.max(1, state.categories.length)).padStart(2, '0');
        els.categoryLabel.textContent = category?.label || 'Directory';
        els.categories.querySelector('.active')?.scrollIntoView({ inline: 'center', block: 'nearest' });
    }

    function renderEntries() {
        const entries = entriesForCategory(selectedCategory());
        if (state.entryIndex >= entries.length) state.entryIndex = Math.max(0, entries.length - 1);

        els.entries.replaceChildren();
        els.entryCount.textContent = `${entries.length} ${entries.length === 1 ? 'RECORD' : 'RECORDS'}`;

        if (!entries.length) {
            const empty = document.createElement('div');
            empty.className = 'empty-state';
            empty.textContent = 'No directory records are registered in this section.';
            els.entries.appendChild(empty);
            return;
        }

        entries.forEach((entry, index) => {
            const button = document.createElement('button');
            button.type = 'button';
            button.className = `entry-button${index === state.entryIndex ? ' active' : ''}`;
            button.setAttribute('role', 'option');
            button.setAttribute('aria-selected', index === state.entryIndex ? 'true' : 'false');
            button.innerHTML = `
                <span class="entry-index">${String(index + 1).padStart(2, '0')}</span>
                <span class="entry-name"><strong></strong><small></small></span>
                <span class="entry-arrow">›</span>`;

            button.querySelector('strong').textContent = entry.label;
            button.querySelector('small').textContent = entry.location || entry.kicker || 'NODE7';
            button.addEventListener('mouseenter', () => {
                if (state.entryIndex !== index) setEntry(index);
            });
            button.addEventListener('click', () => setEntry(index));
            els.entries.appendChild(button);
        });

        els.entries.querySelector('.active')?.scrollIntoView({ block: 'nearest' });
    }

    function runAction(action) {
        const entry = selectedEntry();
        if (!entry || !action) return;
        playSound('select', 0.24);
        post('action', { entryId: entry.id, actionId: action.id });
    }

    function renderDetail() {
        const category = selectedCategory();
        const entries = entriesForCategory(category);
        const entry = selectedEntry();

        els.details.replaceChildren();
        els.actions.replaceChildren();

        els.detailSection.textContent = String(category?.label || 'Directory').toUpperCase();
        els.detailPosition.textContent = `${String(Math.min(state.entryIndex + 1, Math.max(1, entries.length))).padStart(2, '0')} / ${String(Math.max(1, entries.length)).padStart(2, '0')}`;

        if (!entry) {
            els.art.dataset.category = category?.id || 'featured';
            els.monogram.textContent = 'N7';
            els.record.textContent = 'DIRECTORY RECORD';
            els.kicker.textContent = 'NODE7 DIRECTORY';
            els.location.textContent = 'NODE7';
            els.entryTitle.textContent = 'No records available';
            els.description.textContent = 'Another NODE7 resource can register a directory record through the included exports.';
            return;
        }

        els.art.dataset.category = entry.category || category?.id || 'featured';
        els.monogram.textContent = monogram(entry);
        els.record.textContent = recordCode(entry);
        els.kicker.textContent = entry.kicker || 'DIRECTORY';
        els.location.textContent = entry.location || 'NODE7';
        els.entryTitle.textContent = entry.label;
        els.description.textContent = entry.description || '';

        (entry.details || []).forEach(detail => {
            const item = document.createElement('li');
            item.textContent = detail;
            els.details.appendChild(item);
        });

        (entry.actions || []).forEach((action, index) => {
            const button = document.createElement('button');
            button.type = 'button';
            button.className = `action-button${index === 0 ? ' primary' : ''}`;
            button.textContent = action.label || action.id;
            button.addEventListener('click', () => runAction(action));
            els.actions.appendChild(button);
        });
    }

    function render() {
        const normalized = normalize(state.payload || {});
        state.categories = normalized.categories;
        state.entries = normalized.entries;

        if (state.categoryIndex >= state.categories.length) state.categoryIndex = 0;

        renderPlayer();
        renderCategories();
        renderEntries();
        renderDetail();

        const branding = state.payload?.branding || {};
        els.title.textContent = branding.title || 'DIRECTORY';
        els.subtitle.textContent = branding.subtitle || 'NODE7 SERVER GUIDE';
        els.footer.textContent = branding.footer || 'NODE7 DEVELOPMENT STUDIOS';
    }

    function open(payload) {
        state.open = true;
        state.payload = payload || {};
        state.categoryIndex = 0;
        state.entryIndex = 0;
        root.classList.add('is-open');
        root.setAttribute('aria-hidden', 'false');
        render();
        playSound('open', 0.24);
    }

    function close(withSound = false) {
        if (withSound && state.open) playSound('close', 0.2);
        state.open = false;
        root.classList.remove('is-open');
        root.setAttribute('aria-hidden', 'true');
    }

    function requestClose() {
        playSound('close', 0.2);
        post('close');
    }

    window.addEventListener('message', event => {
        const data = event.data || {};
        if (data.action === 'open') open(data.payload);
        if (data.action === 'refresh') {
            state.payload = data.payload || state.payload;
            render();
        }
        if (data.action === 'close') close(false);
    });

    window.addEventListener('keydown', event => {
        if (!state.open) return;

        const key = event.key;
        const lower = key.toLowerCase();

        if (key === 'PageUp' || key === 'Escape' || key === 'Backspace') {
            event.preventDefault();
            requestClose();
            return;
        }

        if (key === 'ArrowLeft' || lower === 'a') {
            event.preventDefault();
            setCategory(state.categoryIndex - 1, true, 'left');
            return;
        }

        if (key === 'ArrowRight' || lower === 'd') {
            event.preventDefault();
            setCategory(state.categoryIndex + 1, true, 'right');
            return;
        }

        if (key === 'ArrowUp' || lower === 'w') {
            event.preventDefault();
            setEntry(state.entryIndex - 1);
            return;
        }

        if (key === 'ArrowDown' || lower === 's') {
            event.preventDefault();
            setEntry(state.entryIndex + 1);
            return;
        }

        if (key === 'Enter') {
            event.preventDefault();
            const entry = selectedEntry();
            if (entry?.actions?.[0]) runAction(entry.actions[0]);
            return;
        }

        if (lower === 'r') {
            const route = selectedEntry()?.actions?.find(action => action.type === 'route');
            if (route) {
                event.preventDefault();
                runAction(route);
            }
        }
    });

    updateClock();
    setInterval(updateClock, 1000);
    close(false);
})();

// Run: TZ=Europe/Paris node --test nord-violet/tests/test_calendar.cjs
const fs = require('node:fs');
const path = require('node:path');
const vm = require('node:vm');
const test = require('node:test');
const assert = require('node:assert/strict');
const dates = {};
vm.createContext(dates);
vm.runInContext(fs.readFileSync(path.join(__dirname,
    '../../quickshell-cc/.config/quickshell/nord-violet-cc/CalendarMath.js'), 'utf8')
    .replace('.pragma library', ''), dates);

for (const [year, month, days] of [[2026, 8, 30], [2024, 1, 29],
    [2100, 1, 28], [2000, 1, 29], [2026, 11, 31], [2026, 2, 31], [2026, 9, 31]]) {
    test(`Monday-first grid ${year}-${month + 1}, including leap/DST boundaries`, () => {
        const cells = dates.cells(dates.day(year, month, 1));
        assert.equal(cells.length, 42);
        assert.equal(cells[0].getDay(), 1);
        assert.equal(cells[41].getDay(), 0);
        assert.equal(cells.filter(d => d.getMonth() === month).length, days);
        for (let i = 1; i < cells.length; i++) {
            assert.ok(dates.sameDay(dates.moveDay(cells[i - 1], 1), cells[i]));
            assert.equal(cells[i].getHours(), 12);
        }
    });
}
test('Month navigation crosses years without skipping February after January 31', () => {
    assert.equal(dates.monthStart(dates.day(2026, 11, 19), 1).getFullYear(), 2027);
    assert.equal(dates.monthStart(dates.day(2026, 0, 31), -1).getFullYear(), 2025);
    assert.equal(dates.monthStart(dates.day(2026, 0, 31), 1).getMonth(), 1);
});
test('Keyboard navigation crosses month boundaries and compares full dates', () => {
    assert.ok(dates.sameDay(dates.moveDay(dates.day(2024, 1, 28), 1), dates.day(2024, 1, 29)));
    assert.ok(dates.sameDay(dates.moveDay(dates.day(2026, 0, 1), -1), dates.day(2025, 11, 31)));
    assert.equal(dates.sameDay(dates.day(2026, 0, 1), dates.day(2025, 0, 1)), false);
});

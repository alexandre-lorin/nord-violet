.pragma library

// Noon keeps calendar arithmetic stable across daylight-saving changes.
function day(year, month, date) { return new Date(year, month, date, 12); }
function sameDay(a, b) {
    return a.getFullYear() === b.getFullYear() && a.getMonth() === b.getMonth()
        && a.getDate() === b.getDate();
}
function monthStart(date, offset) {
    return day(date.getFullYear(), date.getMonth() + offset, 1);
}
function cells(month) {
    const start = monthStart(month, 0);
    const offset = (start.getDay() + 6) % 7;
    const result = [];
    for (let i = 0; i < 42; i++)
        result.push(day(start.getFullYear(), start.getMonth(), 1 - offset + i));
    return result;
}
function moveDay(date, offset) {
    return day(date.getFullYear(), date.getMonth(), date.getDate() + offset);
}

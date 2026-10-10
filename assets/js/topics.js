(function () {
  'use strict';
  var list = document.getElementById('topic-list');
  var search = document.getElementById('topic-search');
  var sort = document.getElementById('topic-sort');
  var status = document.getElementById('topic-status');
  var items = Array.prototype.slice.call(list.children);
  var now = new Date();
  var today = Date.UTC(now.getFullYear(), now.getMonth(), now.getDate());
  var relativeTime = new Intl.RelativeTimeFormat('en', { numeric: 'auto' });

  items.forEach(function (item) {
    var days = Math.round((Date.parse(item.dataset.latest + 'T00:00:00Z') - today) / 86400000);
    var magnitude = Math.abs(days);
    var unit = 'day';
    var divisor = 1;
    if (magnitude >= 365) {
      unit = 'year';
      divisor = 365;
    } else if (magnitude >= 30) {
      unit = 'month';
      divisor = 30;
    } else if (magnitude >= 7) {
      unit = 'week';
      divisor = 7;
    }
    var age = relativeTime.format(Math.trunc(days / divisor), unit);
    item.querySelector('a').title = (item.dataset.description ? item.dataset.description + ' — ' : '') + 'latest ' + age;
  });

  function update() {
    var query = search.value.trim().toLowerCase();
    var visible = 0;
    items.sort(function (a, b) {
      var difference = 0;
      if (sort.value === 'count') difference = Number(b.dataset.count) - Number(a.dataset.count);
      if (sort.value === 'latest') difference = b.dataset.latest.localeCompare(a.dataset.latest);
      return difference || a.dataset.name.localeCompare(b.dataset.name);
    });
    items.forEach(function (item) {
      item.hidden = (item.dataset.name + ' ' + item.dataset.description).toLowerCase().indexOf(query) === -1;
      if (!item.hidden) visible += 1;
      list.appendChild(item);
    });
    status.textContent = visible + ' topics';
  }
  search.addEventListener('input', update);
  sort.addEventListener('change', update);
  update();
}());

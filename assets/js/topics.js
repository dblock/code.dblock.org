(function () {
  'use strict';
  var list = document.getElementById('topic-list');
  var search = document.getElementById('topic-search');
  var sort = document.getElementById('topic-sort');
  var status = document.getElementById('topic-status');
  var items = Array.prototype.slice.call(list.children);

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

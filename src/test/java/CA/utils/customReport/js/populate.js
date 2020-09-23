var populateTable = (data) => {
  var table = document.getElementById('results');
  for(let i = 0; i < data.length; i++) {
    var rowData = data[i];
    var row = table.insertRow(table.length);
    let j = 0;
    for(let key in rowData) {
      var cell = row.insertCell(j);
      j++;
      cell.innerHTML = rowData[key];
      $(cell).addClass(rowData[key]);
    }
  }
}

$(document).ready(
  () => {
    populateTable(data);
  }
)
var populateTable = (data) => {
  for(let i = 0; i < data.length; i++) {
    var rowData = data[i];
    var table = document.getElementById(rowData['tableName']);
    var row = table.insertRow(table.length);
    
    let j = 0;
    for(let key in rowData) {
      if(key == 'tableName') {
        continue;
      }
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
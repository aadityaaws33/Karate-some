const isUnique = (value, index, self) => {
  return self.indexOf(value) === index
}

var populateTable = (data) => {
  // Table Headers
  var headers = [];
  for(let i = 0; i < data.length; i++) {
    var rowData = data[i];
    headers.push(...Object.keys(rowData));
  }
  headers = headers.filter(isUnique);
  headers.splice(headers.indexOf('tableName'),1);
  var htmlTable = document.getElementById(rowData['tableName']);
  var row = htmlTable.insertRow(htmlTable.length);
  for(let i = 0; i < headers.length; i++) {
    var header = headers[i];
    var cell = row.insertCell(i);
    cell.innerHTML = header;
  }
  
  for(let i = 0; i < data.length; i++) {
    var rowData = data[i];
    var htmlTable = document.getElementById(rowData['tableName']);
    var row = htmlTable.insertRow(htmlTable.length);
    
    for(let j = 0; j < headers.length; j++) {
      var header = headers[j];
      var cell = row.insertCell(j);
      var cellValue = 'NotApplicable';
      if(rowData.hasOwnProperty(header)) {
        cellValue = rowData[header];
      } 
      cell.innerHTML = cellValue;
      $(cell).addClass(cellValue);
    }
  }
}

$(document).ready(
  () => {
    populateTable(data);
  }
)
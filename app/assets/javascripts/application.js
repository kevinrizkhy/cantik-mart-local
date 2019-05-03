// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, or any plugin's
// vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require rails-ujs
//= require activestorage
//= require_tree .

var add_counter = gon.inv_count;

function changeSupplier(){
	var supplier_id = $( "#supplierId" ).val();
	var base = window.location.href.split("?")[0];
	var url = base+"?supplier_id="+supplier_id;
    window.location.href = url;
}

function removeThisRow(params){
	var row_idx = params.parentNode.parentNode.rowIndex;
	var table = document.getElementById("myTable");
	if(table.rows.length > 2){
		table.deleteRow(row_idx);
	}
}

function addNewRow(){
	var table = document.getElementById("myTable");
	var row = table.insertRow(table.rows.length);

	var cell1 = row.insertCell(0);
	var cell2 = row.insertCell(1);
	var cell3 = row.insertCell(2);
	var cell4 = row.insertCell(3);
	var cell5 = row.insertCell(4);

	cell1.innerHTML = '<select id="selectpicker'+add_counter+'" class="selectpicker form-control" data-show-subtext="true" data-live-search="true" name="order[order_items]['+add_counter+'][item_id]">'+
	gon.select_options+'</select>';
	cell2.innerHTML = '<input type="number" required=true class="form-control" id="quantity" name="order[order_items]['+add_counter+'][quantity]">'; 
	cell3.innerHTML = '<input type="number" required=true class="form-control" id="quantity" name="order[order_items]['+add_counter+'][price]">'; 
	cell4.innerHTML = '<input type="textarea" required=true class="form-control" id="description" name="order[order_items]['+add_counter+'][description]">'; 
	cell5.innerHTML = "<i class='fa fa-trash text-danger' onclick='removeThisRow(this)'></i>"; 

	$('#selectpicker'+add_counter).selectpicker('refresh');
	add_counter++;
}

function addNewRowRetur(){
	var table = document.getElementById("myTable");
	var row = table.insertRow(table.rows.length);

	var cell1 = row.insertCell(0);
	var cell2 = row.insertCell(1);
	var cell3 = row.insertCell(2);
	var cell4 = row.insertCell(3);

	cell1.innerHTML = '<select id="selectpicker'+add_counter+'" class="selectpicker form-control" data-show-subtext="true" data-live-search="true" name="retur[retur_items]['+add_counter+'][item_id]">'+
	gon.select_options+'</select>';
	cell2.innerHTML = '<input type="number" required=true class="form-control" id="quantity" name="retur[retur_items]['+add_counter+'][quantity]">'; 
	cell3.innerHTML = '<input type="textarea" required=true class="form-control" id="description" name="retur[retur_items]['+add_counter+'][description]">'; 
	cell4.innerHTML = "<i class='fa fa-trash text-danger' onclick='removeThisRow(this)'></i>"; 

	$('#selectpicker'+add_counter).selectpicker('refresh');
	add_counter++;
}

function addNewRowComplain(){
	var table = document.getElementById("myTable");
	var row = table.insertRow(table.rows.length);

	var cell1 = row.insertCell(0);
	var cell2 = row.insertCell(1);
	var cell3 = row.insertCell(2);
	var cell4 = row.insertCell(3);
	var cell5 = row.insertCell(4);
	var cell6 = row.insertCell(5);	
	var cell7 = row.insertCell(6);

	cell1.innerHTML = '<select id="selectpicker'+add_counter+'" class="selectpicker form-control" data-show-subtext="true" data-live-search="true" name="complain[complain_items]['+add_counter+'][item_id]">'+
	gon.select_options+'</select>';
	cell2.innerHTML = '<input type="number" required=true class="form-control" id="quantity" name="complain[complain_items]['+add_counter+'][price]">';
	cell3.innerHTML = '<input type="number" required=true class="form-control" id="quantity" name="complain[complain_items]['+add_counter+'][discount]">';  
	cell4.innerHTML = '<input type="number" required=true class="form-control" id="quantity" name="complain[complain_items]['+add_counter+'][quantity]" readonly value=0>'; 
	cell5.innerHTML = '<input type="number" required=true class="form-control" id="quantity" name="complain[complain_items]['+add_counter+'][new_quantity]">'; 
	cell6.innerHTML = '<input type="textarea" required=true class="form-control" id="description" name="complain[complain_items]['+add_counter+'][description]">'; 
	cell7.innerHTML = "<i class='fa fa-trash text-danger' onclick='removeThisRow(this)'></i>"; 

	$('#selectpicker'+add_counter).selectpicker('refresh');
	add_counter++;
}

var ctx = document.getElementById("debt-chart").getContext('2d');

var debt = new Chart(ctx, {
    type: 'line',
    data: {
      labels: gon.labels,
      datasets: gon.datasets,
    },
    options: {
      responsive: true
    }
  });

$(document).ready(function() {
	$('select').selectpicker();
});
setInterval(get_notification, 15000);


function update_notification()
{
  
}

function get_notification(){
  last_check = document.getElementById("last_check").value;
  $.ajax({ 
    type: 'GET', 
    url: '/api/get_notification?t='+last_check, 
    success: function (data) { 
      data_length = data.length;
      if (data_length > 1) {
        // alert(JSON.stringify(data));
      }else{
        document.getElementById("last_check").value = data[0];
      }
    }
  });
}

function removeThisRow(params){
	var row_idx = params.parentNode.parentNode.rowIndex;
	var table = document.getElementById("myTable");
	if(table.rows.length > 2){
		table.deleteRow(row_idx);
	}
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

	cell1.innerHTML = '<select id="selectpicker'+add_counter+'" class="mdb-select md-outline colorful-select dropdown-primary" searchable="Cari..." name="complain[complain_items]['+add_counter+'][item_id]">'+
	gon.select_options+'</select>';
	cell2.innerHTML = '<input type="number" required=true class="form-control" id="quantity" name="complain[complain_items]['+add_counter+'][price]">';
	cell3.innerHTML = '<input type="number" required=true class="form-control" id="quantity" name="complain[complain_items]['+add_counter+'][discount]">';  
	cell4.innerHTML = '<input type="number" required=true class="form-control" id="quantity" name="complain[complain_items]['+add_counter+'][quantity]" readonly value=0>'; 
	cell5.innerHTML = '<input type="number" required=true class="form-control" id="quantity" name="complain[complain_items]['+add_counter+'][new_quantity]">'; 
	cell6.innerHTML = '<input type="textarea" required=true class="form-control" id="description" name="complain[complain_items]['+add_counter+'][description]">'; 
	cell7.innerHTML = "<i class='fa fa-trash text-danger' onclick='removeThisRow(this)'></i>"; 

	$('#selectpicker'+add_counter).material_select();
	add_counter++;
}

// var ctx = document.getElementById("debt-chart").getContext('2d');

// var debt = new Chart(ctx, {
//   type: 'line',
//   data: {
//     labels: gon.labels,
//     datasets: gon.datasets,
//   },
//   options: {
//     responsive: true
//   }
// });

    // SideNav Initialization
$(".button-collapse").sideNav();

var container = document.querySelector('.custom-scrollbar');
var ps = new PerfectScrollbar(container, {
  wheelSpeed: 2,
  wheelPropagation: true,
  minScrollbarLength: 20
});

// Data Picker Initialization
$('.datepicker').pickadate();

// Material Select Initialization
$(document).ready(function () {
  $('.mdb-select').material_select();
});

// Tooltips Initialization
$(function () {
  $('[data-toggle="tooltip"]').tooltip()
})

// Small chart
$(function () {
  $('.min-chart#chart-sales').easyPieChart({
    barColor: "#FF5252",
    onStep: function (from, to, percent) {
      $(this.el).find('.percent').text(Math.round(percent));
    }
  });
});

    // Main chart
// var ctxL = document.getElementById("lineChart").getContext('2d');
// var myLineChart = new Chart(ctxL, {
//   type: 'line',
//   data: {
//     labels: ["January", "February", "March", "April", "May", "June", "July"],
//     datasets: [{
//       label: "My First dataset",
//       fillColor: "#fff",
//       backgroundColor: 'rgba(255, 255, 255, .3)',
//       borderColor: 'rgba(255, 255, 255)',
//       data: [0, 10, 5, 2, 20, 30, 45],
//     }]
//   },
//   options: {
//     legend: {
//       labels: {
//         fontColor: "#fff",
//       }
//     },
//     scales: {
//       xAxes: [{
//         gridLines: {
//           display: true,
//           color: "rgba(255,255,255,.25)"
//         },
//         ticks: {
//           fontColor: "#fff",
//         },
//       }],
//       yAxes: [{
//         display: true,
//         gridLines: {
//           display: true,
//           color: "rgba(255,255,255,.25)"
//         },
//         ticks: {
//           fontColor: "#fff",
//         },
//       }],
//     }
//   }
// });

var timeout = null;

function getData(table_types) {
   clearTimeout(timeout);
   timeout = setTimeout(function() {
     var item_id = document.getElementById("itemId").value;
     $.ajax({
       method: "GET",
       cache: false,
       url: "/api/order?search=" + item_id,
       success: function(result_arr) {
           if (table_types == "order"){
            addNewRowOrder(result_arr);
           }
           else if(table_types == "retur"){
            addNewRowRetur(result_arr);
           }else if (table_types == "transfer"){
            addNewRowTransfer(result_arr);
           }
       },
       error: function(error) {
           document.getElementById("itemId").value = "";
           document.getElementById("item_qty").value = 1;
           document.getElementById("itemId").focus();
       }
     });
   }, 300);
};

function addNewRowOrder(result_arr){
   var table = document.getElementById("myTable");
   var result = result_arr[0];
   var qty = 1;
   var total = parseFloat(qty) * (parseFloat(result[3]) - parseFloat("100"));
   
   var row = table.insertRow(-1);
   var cell1 = row.insertCell(0);
   var cell2 = row.insertCell(1);
   var cell3 = row.insertCell(2);
   var cell4 = row.insertCell(3);
   var cell5 = row.insertCell(4);
   var cell6 = row.insertCell(5);
   var cell7 = row.insertCell(6);


   let id = "<input style='display: none;' type='text' class='md-form form-control' value='"+result[4]+"' readonly name='order[order_items]["+add_counter+"][item_id]'/>";
   let code = id+"<input type='text' class='md-form form-control' value='"+result[0]+"' readonly name='order[order_items]["+add_counter+"][code]'/>";
   let name = "<input type='text' class='md-form form-control' value='"+result[1]+"' readonly name='order[order_items]["+add_counter+"][name]'/>";
   let cat = "<input type='text' class='md-form form-control' value='"+result[2]+"' readonly name='order[order_items]["+add_counter+"][item_cat]'/>";
   let quantity = "<input type='number' min=1 class='md-form form-control' value='1' name='order[order_items]["+add_counter+"][quantity]'/>";
   let price = "<input type='number' class='md-form form-control' value='100' min=100 name='order[order_items]["+add_counter+"][price]'/>";
   let desc = "<input type='text' class='md-form form-control' value=''  name='order[order_items]["+add_counter+"][description]'/>";
   let remove = "<i class='fa fa-trash text-danger' onclick='removeThisRow(this)'></i>"; 
   cell1.innerHTML = code;
   cell2.innerHTML = name;
   cell3.innerHTML = cat;
   cell4.innerHTML = quantity;
   cell5.innerHTML = price;
   cell6.innerHTML = desc;
   cell7.innerHTML = remove;
   add_counter++;
   document.getElementById("itemId").value = "";
}

function addNewRowRetur(result_arr){
   var table = document.getElementById("myTable");
   var result = result_arr[0];
   var qty = 1;
   var total = parseFloat(qty) * (parseFloat(result[3]) - parseFloat("100"));
   
   var row = table.insertRow(-1);
   var cell1 = row.insertCell(0);
   var cell2 = row.insertCell(1);
   var cell3 = row.insertCell(2);
   var cell4 = row.insertCell(3);
   var cell5 = row.insertCell(4);
   var cell6 = row.insertCell(5);


   let id = "<input style='display: none;' type='text' class='md-form form-control' value='"+result[4]+"' readonly name='order[order_items]["+add_counter+"][item_id]'/>";
   let code = id+"<input type='text' class='md-form form-control' value='"+result[0]+"' readonly name='order[order_items]["+add_counter+"][code]'/>";
   let name = "<input type='text' class='md-form form-control' value='"+result[1]+"' readonly name='order[order_items]["+add_counter+"][name]'/>";
   let cat = "<input type='text' class='md-form form-control' value='"+result[2]+"' readonly name='order[order_items]["+add_counter+"][item_cat]'/>";
   let quantity = "<input type='number' min=1 class='md-form form-control' value='1' name='order[order_items]["+add_counter+"][quantity]'/>";
   let desc = "<input type='text' class='md-form form-control' value=''  name='order[order_items]["+add_counter+"][description]'/>";
   let remove = "<i class='fa fa-trash text-danger' onclick='removeThisRow(this)'></i>"; 
   cell1.innerHTML = code;
   cell2.innerHTML = name;
   cell3.innerHTML = cat;
   cell4.innerHTML = quantity;
   cell5.innerHTML = desc;
   cell6.innerHTML = remove;
   add_counter++;
   document.getElementById("itemId").value = "";
}

function addNewRowTransfer(result_arr){
   var table = document.getElementById("myTable");
   var result = result_arr[0];
   var qty = 1;
   var total = parseFloat(qty) * (parseFloat(result[3]) - parseFloat("100"));
   
   var row = table.insertRow(-1);
   var cell1 = row.insertCell(0);
   var cell2 = row.insertCell(1);
   var cell3 = row.insertCell(2);
   var cell4 = row.insertCell(3);
   var cell5 = row.insertCell(4);
   var cell6 = row.insertCell(5);


   let id = "<input style='display: none;' type='text' class='md-form form-control' value='"+result[4]+"' readonly name='transfer[transfer_items]["+add_counter+"][item_id]'/>";
   let code = id+"<input type='text' class='md-form form-control' value='"+result[0]+"' readonly />";
   let name = "<input type='text' class='md-form form-control' value='"+result[1]+"' readonly />";
   let cat = "<input type='text' class='md-form form-control' value='"+result[2]+"' readonly />";
   let quantity = "<input type='number' min=1 class='md-form form-control' value='1' name='transfer[transfer_items]["+add_counter+"][quantity]'/>";
   let desc = "<input type='text' class='md-form form-control' value=''  name='transfer[transfer_items]["+add_counter+"][description]'/>";
   let remove = "<i class='fa fa-trash text-danger' onclick='removeThisRow(this)'></i>"; 
   cell1.innerHTML = code;
   cell2.innerHTML = name;
   cell3.innerHTML = cat;
   cell4.innerHTML = quantity;
   cell5.innerHTML = desc;
   cell6.innerHTML = remove;
   add_counter++;
   document.getElementById("itemId").value = "";
}
     

$(function () {
  $('#dark-mode').on('click', function (e) {

    e.preventDefault();
    $('h4, button').not('.check').toggleClass('dark-grey-text text-white');
    $('.list-panel a').toggleClass('dark-grey-text');

    $('footer, .card').toggleClass('dark-card-admin');
    $('body, .navbar').toggleClass('white-skin navy-blue-skin');
    $(this).toggleClass('white text-dark btn-outline-black');
    $('body').toggleClass('dark-bg-admin');
    $('h6, .card, p, td, th, i, li a, h4, input, label').not(
      '#slide-out i, #slide-out a, .dropdown-item i, .dropdown-item').toggleClass('text-white');
    $('.btn-dash').toggleClass('grey blue').toggleClass('lighten-3 darken-3');
    $('.gradient-card-header').toggleClass('white black lighten-4');
    $('.list-panel a').toggleClass('navy-blue-bg-a text-white').toggleClass('list-group-border');

  });
});



var add_counter = gon.inv_count;
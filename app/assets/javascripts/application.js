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

	cell1.innerHTML = '<select id="selectpicker'+add_counter+'" class="mdb-select md-outline colorful-select dropdown-primary" searchable="Cari..." name="order[order_items]['+add_counter+'][item_id]">'+
	gon.select_options+'</select>';
	cell2.innerHTML = '<input type="number" required=true class="form-control" id="quantity" name="order[order_items]['+add_counter+'][quantity]">'; 
	cell3.innerHTML = '<input type="number" required=true class="form-control" id="quantity" name="order[order_items]['+add_counter+'][price]">'; 
	cell4.innerHTML = '<input type="textarea" required=true class="form-control" id="description" name="order[order_items]['+add_counter+'][description]">'; 
	cell5.innerHTML = "<i class='fa fa-trash text-danger' onclick='removeThisRow(this)'></i>"; 

	$('#selectpicker'+add_counter).material_select();
	add_counter++;
}

function addNewRowRetur(){
	var table = document.getElementById("myTable");
	var row = table.insertRow(table.rows.length);

	var cell1 = row.insertCell(0);
	var cell2 = row.insertCell(1);
	var cell3 = row.insertCell(2);
	var cell4 = row.insertCell(3);

	cell1.innerHTML = '<select id="selectpicker'+add_counter+'" class="mdb-select md-outline colorful-select dropdown-primary" searchable="Cari..." name="retur[retur_items]['+add_counter+'][item_id]">'+
	gon.select_options+'</select>';
	cell2.innerHTML = '<input type="number" required=true class="form-control" id="quantity" name="retur[retur_items]['+add_counter+'][quantity]">'; 
	cell3.innerHTML = '<input type="textarea" required=true class="form-control" id="description" name="retur[retur_items]['+add_counter+'][description]">'; 
	cell4.innerHTML = "<i class='fa fa-trash text-danger' onclick='removeThisRow(this)'></i>"; 

	// $('#selectpicker'+add_counter).selectpicker('refresh');
	$('#selectpicker'+add_counter).material_select();
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
    var ctxL = document.getElementById("lineChart").getContext('2d');
    var myLineChart = new Chart(ctxL, {
      type: 'line',
      data: {
        labels: ["January", "February", "March", "April", "May", "June", "July"],
        datasets: [{
          label: "My First dataset",
          fillColor: "#fff",
          backgroundColor: 'rgba(255, 255, 255, .3)',
          borderColor: 'rgba(255, 255, 255)',
          data: [0, 10, 5, 2, 20, 30, 45],
        }]
      },
      options: {
        legend: {
          labels: {
            fontColor: "#fff",
          }
        },
        scales: {
          xAxes: [{
            gridLines: {
              display: true,
              color: "rgba(255,255,255,.25)"
            },
            ticks: {
              fontColor: "#fff",
            },
          }],
          yAxes: [{
            display: true,
            gridLines: {
              display: true,
              color: "rgba(255,255,255,.25)"
            },
            ticks: {
              fontColor: "#fff",
            },
          }],
        }
      }
    });

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


// setInterval(get_notification, 10000);

function formatangka_titik(total) {
  var a = (total+"").replace(/[^\d]/g, "");

  var a = +a; // converts 'a' from a string to an int

  return formatNum(a);
}

function formatNum(rawNum) {
  rawNum = "" + rawNum; // converts the given number back to a string
  var retNum = "";
  var j = 0;
  for (var i = rawNum.length; i > 0; i--) {
    j++;
    if (((j % 3) == 1) && (j != 1))
      retNum = rawNum.substr(i - 1, 1) + "." + retNum;
    else
      retNum = rawNum.substr(i - 1, 1) + retNum;
  }
  return retNum;
}

$(document).keypress(
  function(event){
    if (event.which == '13') {
      event.preventDefault();
    }
});

function removeThisRow(params){
	var row_idx = params.parentNode.parentNode.rowIndex;
	var table = document.getElementById("myTable");
	if(table.rows.length > 1){
		table.deleteRow(row_idx);
	}
}

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


var timeout = null;

function getData(table_types) {
   clearTimeout(timeout);
   timeout = setTimeout(function() {
     var item_id = document.getElementById("itemId").value;
     if(table_types=="complain"){
        var item_qty = document.getElementById("searchqty").value;
        $.ajax({
         method: "GET",
         cache: false,
         url: "/api/trx?search=" + item_id +"&qty=" + item_qty,
         success: function(result_arr) {
            if(result_arr == ""){
              document.getElementById("itemId").value = "";
              alert("Data Barang Tidak Ditemukan")
              return
            }else{
              addNewRowComplain(result_arr, item_qty);
            }
         },
         error: function(error) {
             document.getElementById("itemId").value = "";
             document.getElementById("searchqty").value = 1;
             document.getElementById("itemId").focus();
         }
       });
     }else{
      $.ajax({
         method: "GET",
         cache: false,
         url: "/api/order?search=" + item_id,
         success: function(result_arr) {
            if(result_arr == ""){
              document.getElementById("itemId").value = "";
              alert("Data Barang Tidak Ditemukan")
              return
            }else{
               if (table_types == "order"){
                addNewRowOrder(result_arr);
               }
               else if(table_types == "retur"){
                addNewRowRetur(result_arr);
               }else if (table_types == "transfer"){
                addNewRowTransfer(result_arr);
               }
             }
         },
         error: function(error) {
             document.getElementById("itemId").value = "";
             document.getElementById("item_qty").value = 1;
             document.getElementById("itemId").focus();
         }
       });
    }
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
   let price = "<input type='number' class='md-form form-control' value='"+result[3]+"' min=100 name='order[order_items]["+add_counter+"][price]'/>";
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


// var add_counter = gon.inv_count;
var add_counter = 0

var ctxP = document.getElementById("higher_sales").getContext('2d');
var myPieChart = new Chart(ctxP, {
  type: 'doughnut',
  data: {
    labels: gon.higher_item_cats_label,
    datasets: [{
      data: gon.higher_item_cats_data,
      backgroundColor: ["#F7464A", "#46BFBD", "#FDB45C", "#949FB1", "#4D5360"],
      hoverBackgroundColor: ["#FF5A5E", "#5AD3D1", "#FFC870", "#A8B3C5", "#616774"]
    }]
  },
  options: {
    responsive: true
  }
});

var ctxP = document.getElementById("lower_sales").getContext('2d');
var myPieChart = new Chart(ctxP, {
  type: 'doughnut',
  data: {
    labels: gon.lower_item_cats_label,
    datasets: [{
      data: gon.lower_item_cats_data,
      backgroundColor: ["rgba(255, 99, 132, 0.2)", "rgba(255, 159, 64, 0.2)",
        "rgba(255, 205, 86, 0.2)", "rgba(75, 192, 192, 0.2)", "rgba(54, 162, 235, 0.2)",
        "rgba(153, 102, 255, 0.2)", "rgba(201, 203, 207, 0.2)"
      ],
      hoverBackgroundColor: ["#FF5A5E", "#5AD3D1", "#FFC870", "#A8B3C5", "#616774"]
    }]
  },
  options: {
    responsive: true
  }
});



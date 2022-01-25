// setInterval(get_notification, 10000);

var separator = '<p class="medium">===========================================================</p>';

var header_cirata = '<!DOCTYPE html> <html> <head> <meta content="text/html;charset=utf-8" http-equiv="Content-Type"> <meta content="utf-8" http-equiv="encoding"> <style type="text/css"> table {table-layout:auto; width:100%;} td { font-size: 15px; padding: 0 !important; border-top: none !important;} </style> <title></title> </head> <body> ' + '<table widht: "100%;" ><tr><td style="text-align: left; vertical-align: middle;"><img src="/images/logo.png" style="width: 150px"/></td><td style="text-align: right;font-size: 12px !important;">' + 'PT. Cantik Berkah Sejahtera <br>' + 'NPWP: 53.925.657.9-409.000 <br>' +  'Jl. Cirata - Cilangkap, Ds. Cadassari<br> Kec. Tegalwaru, Kabupaten Purwakarta,<br>Jawa Barat'+'</td></tr></table>'+separator;

var header_plered = '<!DOCTYPE html> <html> <head> <meta content="text/html;charset=utf-8" http-equiv="Content-Type"> <meta content="utf-8" http-equiv="encoding"> <style type="text/css"> table {table-layout:auto; width:100%;} td { font-size: 15px; padding: 0 !important; border-top: none !important;} </style> <title></title> </head> <body> ' + '<table widht: "100%;" ><tr><td style="text-align: left; vertical-align: middle;"><img src="/images/logo.png" style="width: 150px"/></td><td style="text-align: right;font-size: 12px !important;">' + 'PT. Cantik Berkah Sejahtera <br>' + 'NPWP: 53.925.657.9-409.000 <br>' + 'Jl. Raya Plered, Purwakarta <br> Kec. Plered, Kabupaten Purwakarta, <br>Jawa Barat'+'</td></tr></table>'+separator;


var head = ' <div class="col-sm-12 text-left"><table class="table">';

function printShift(total, cashier, time, cash, debit, n_trx, store_id,store_name){
  var data = "";  
  if (store_id == 2){
    data += header_cirata;
  }else{
    data += header_plered;
  }
  data += '<table><tr><td style="text-align: center; font-size: 15px;">LAPORAN SHIFT</td></tr></table>'+separator;
  data += '<table><tr><td>Kasir</td> <td>:</td> <td>'+cashier+'</td></tr>';
  data += '<tr><td>Toko</td> <td>:</td> <td>'+store_name+'</td></tr>';
  data += '<tr><td>Waktu</td> <td>:</td> <td>'+time+'</td></tr>';
  data += '<tr><td>Jumlah Struk</td> <td>:</td> <td>'+n_trx+' x</td></tr>';
  data += '<tr><td colspan=3>'+separator+'</td></tr>';
  data += '<tr><td>TUNAI</td> <td>:</td> <td>'+splitRibuan(cash)+'</td></tr>';
  data += '<tr><td>DEBIT</td> <td>:</td> <td>'+splitRibuan(debit)+'</td></tr>';
  data += '<tr><td>TOTAL</td> <td>:</td> <td>'+splitRibuan(total)+'</td></tr>';
  data += '<tr><td>SELISIH</td> <td>:</td> <td><br><br><br></td></tr>';
  data += '</table>';
  data += separator;
  data += '<table><tr><td style="text-align: center;">TTD<br><br><br><br><br>Kepala Toko</td>';
  data += '<td style="text-align: center;">TTD<br><br><br><br><br>'+cashier+'</td></tr></table>';

  printHTML(data);
                 
}

function printHTML(html) {
  var wnd = window.open("about:blank", "", "_blank");
  wnd.document.write(html);
  wnd.print();
}


function splitRibuan(total){
  var bilangan = total;
 
 var reverse = bilangan.toString().split('').reverse().join(''),
 ribuan = reverse.match(/\d{1,3}/g);
 ribuan = ribuan.join('.').split('').reverse().join('');
 return ribuan;
}

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



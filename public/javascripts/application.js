
function ShowHideTab(val){
	
	if(val=='employment'){
		$('#employment').show();
        	$('#financial_comment').hide();
		$('#employment_block').show();
		$('#personal_block').hide();
		$('#financial_block').hide();
		$('#tila_block').hide();
		$('#summary_block').hide();
		$('#factor_trust_block').hide();
		$('#comments_block').hide();
		$('#logs_block').hide();
		$('#documents_block').hide();
		
		$('#verify_button').hide();
		$('#verify_button_f').hide();
		$('#verify_tila_button').hide();
		
		document.getElementById('disclosed_finance_charge_amount').focus();
		document.getElementById("employment_link").className="content-box-tabs default-tab current";
		document.getElementById("personal_link").className="";
		document.getElementById("financial_link").className="";
		document.getElementById("tila_link").className="";
		document.getElementById("summary_link").className="";
		document.getElementById("factor_trust_link").className="";
		document.getElementById("comments_link").className="";
		document.getElementById("documents_link").className="";
	}
	if(val=='financial'){
		$('#financial').show();
		//$('#financial_comment').show();
		$('#employment_block').hide();
		$('#personal_block').hide();
                $('#financial_block').show();
                if(typeof(fin_form) == 'undefined')
                  $('#financial_block').show();
                else if(fin_form == 'edit')
                  $('#financial_block').hide();
		$('#tila_block').hide();
		$('#summary_block').hide();
		$('#factor_trust_block').hide();
		$('#comments_block').hide();
		$('#logs_block').hide();
		$('#documents_block').hide();
		
		$('#verify_button').hide();
		$('#verify_button_f').show();
		$('#verify_tila_button').hide();
		
		document.getElementById('disclosed_finance_charge_amount').focus();
		document.getElementById("employment_link").className="";
		document.getElementById("personal_link").className="";
		document.getElementById("financial_link").className="content-box-tabs default-tab current";
		document.getElementById("tila_link").className="";
		document.getElementById("summary_link").className="";
		//document.getElementById("summary_reject_link").className="";
		document.getElementById("factor_trust_link").className="";
		document.getElementById("comments_link").className="";
		document.getElementById("documents_link").className="";
	}
	if(val=='personal'){
		$('#personal').show();
		
		$('#employment_block').hide();
		$('#personal_block').show();
		$('#financial_block').hide();
		$('#tila_block').hide();
		$('#summary_block').hide();
		$('#factor_trust_block').hide();
		$('#comments_block').hide();
		$('#logs_block').hide();
		$('#documents_block').hide();
		
		$('#verify_button').show();
		$('#verify_button_f').hide();
		$('#verify_tila_button').hide();
		
		document.getElementById('disclosed_finance_charge_amount').focus();
		document.getElementById("employment_link").className="";
		document.getElementById("personal_link").className="content-box-tabs default-tab current";
		document.getElementById("financial_link").className="";
		document.getElementById("tila_link").className="";
		document.getElementById("summary_link").className="";
		//document.getElementById("summary_reject_link").className="";
		document.getElementById("factor_trust_link").className="";
		document.getElementById("comments_link").className="";
		document.getElementById("documents_link").className="";
	}
	if(val=='tila'){
		$('#tila').show();
		
		$('#employment_block').hide();
		$('#personal_block').hide();
		$('#financial_block').hide();
		$('#tila_block').show();
		$('#summary_block').hide();
		$('#factor_trust_block').hide();
		$('#logs_block').hide();
		$('#comments_block').hide();
		$('#documents_block').hide();
		
		$('#verify_button').hide();
		$('#verify_button_f').hide();
		$('#verify_tila_button').show();
		
		document.getElementById('disclosed_finance_charge_amount').focus();
		document.getElementById("employment_link").className="";
		document.getElementById("personal_link").className="";
		document.getElementById("financial_link").className="";
		document.getElementById("tila_link").className="content-box-tabs default-tab current";
		document.getElementById("summary_link").className="";
		//document.getElementById("summary_reject_link").className="";
		document.getElementById("factor_trust_link").className="";
		document.getElementById("comments_link").className="";
		document.getElementById("logs_link").className="";
		document.getElementById("documents_link").className="";
	}
	if(val=='summary'){
		
		
		$('#summary').show();
		
		$('#employment_block').hide();
		$('#personal_block').hide();
		$('#financial_block').hide();
		$('#tila_block').hide();
		$('#summary_block').show();
		$('#factor_trust_block').hide();
		$('#logs_block').hide();
		$('#comments_block').hide();
		$('#documents_block').hide();
		
		$('#verify_button').hide();
		$('#verify_button_f').hide();
		$('#verify_tila_button').hide();
		
		document.getElementById('disclosed_finance_charge_amount').focus();
		document.getElementById("employment_link").className="";
		document.getElementById("personal_link").className="";
		document.getElementById("financial_link").className="";
		document.getElementById("tila_link").className="";
		document.getElementById("summary_link").className="content-box-tabs default-tab current";
		//document.getElementById("summary_reject_link").className="";
		document.getElementById("factor_trust_link").className="";
		document.getElementById("comments_link").className="";
		document.getElementById("logs_link").className="";
		document.getElementById("documents_link").className="";
	}
	if(val=='factor_trust'){
		
		$('#factor_trust').show();
		
		$('#employment_block').hide();
		$('#personal_block').hide();
		$('#financial_block').hide();
		$('#tila_block').hide();
		$('#summary_block').hide();
		$('#factor_trust_block').show();
		$('#comments_block').hide();
		$('#logs_block').hide();
		$('#documents_block').hide();
		
		$('#verify_button').hide();
		$('#verify_button_f').hide();
		$('#verify_tila_button').hide();
		
		document.getElementById('disclosed_finance_charge_amount').focus();
		document.getElementById("employment_link").className="";
		document.getElementById("personal_link").className="";
		document.getElementById("financial_link").className="";
		document.getElementById("tila_link").className="";
		document.getElementById("summary_link").className="";
		//document.getElementById("summary_reject_link").className="";
		document.getElementById("factor_trust_link").className="content-box-tabs default-tab current";
		document.getElementById("comments_link").className="";
		document.getElementById("logs_link").className="";
		document.getElementById("documents_link").className="";
	}
	if(val=='comments_tab'){
		$('#comments_tab').show();
		$('#comments_tab').show();
		
		$('#employment_block').hide();
		$('#personal_block').hide();
		$('#financial_block').hide();
		$('#tila_block').hide();
		$('#summary_block').hide();
		$('#factor_trust_block').hide();
		$('#comments_block').show();
		$('#logs_block').hide();
		$('#documents_block').hide();
		
		$('#verify_button').hide();
		$('#verify_button_f').hide();
		$('#verify_tila_button').hide();
		//alert("hi");
		document.getElementById('disclosed_finance_charge_amount').focus();
		document.getElementById("employment_link").className="";
		document.getElementById("personal_link").className="";
		document.getElementById("financial_link").className="";
		document.getElementById("tila_link").className="";
		document.getElementById("summary_link").className="";
		//document.getElementById("summary_reject_link").className="";
		document.getElementById("factor_trust_link").className="";
		document.getElementById("comments_link").className="content-box-tabs default-tab current";
		document.getElementById("logs_link").className="";
		document.getElementById("documents_link").className="";
	}
	if(val=='logs'){
		
		$('#logs').show();
		
		$('#employment_block').hide();
		$('#personal_block').hide();
		$('#financial_block').hide();
		$('#tila_block').hide();
		$('#summary_block').hide();
		$('#factor_trust_block').hide();
		$('#comments_block').hide();
		$('#logs_block').show();
		$('#documents_block').hide();
		
		$('#verify_button').hide();
		$('#verify_button_f').hide();
		$('#verify_tila_button').hide();
		
		document.getElementById('disclosed_finance_charge_amount').focus();
		document.getElementById("employment_link").className="";
		document.getElementById("personal_link").className="";
		document.getElementById("financial_link").className="";
		document.getElementById("tila_link").className="";
		document.getElementById("summary_link").className="";
		//document.getElementById("summary_reject_link").className="";
		document.getElementById("factor_trust_link").className="";
		document.getElementById("comments_link").className="";
		document.getElementById("logs_link").className="content-box-tabs default-tab current";
		document.getElementById("documents_link").className="";
	}
	if(val=='documents'){
		
		$('#documents').show();
		
		$('#employment_block').hide();
		$('#personal_block').hide();
		$('#financial_block').hide();
		$('#tila_block').hide();
		$('#summary_block').hide();
		$('#factor_trust_block').hide();
		$('#comments_block').hide();
		$('#logs_block').hide();
		$('#documents_block').show();
		
		$('#verify_button').hide();
		$('#verify_button_f').hide();
		$('#verify_tila_button').hide();
		
		document.getElementById('disclosed_finance_charge_amount').focus();
		document.getElementById("employment_link").className="";
		document.getElementById("personal_link").className="";
		document.getElementById("financial_link").className="";
		document.getElementById("tila_link").className="";
		document.getElementById("summary_link").className="";
		//document.getElementById("summary_reject_link").className="";
		document.getElementById("factor_trust_link").className="";
		document.getElementById("comments_link").className="";
		document.getElementById("logs_link").className="";
		document.getElementById("documents_link").className="content-box-tabs default-tab current";
	}
}
function ShowWithReject(){
 $('#summary').show();

  $('#employment_block').hide();
  $('#personal_block').hide();
  $('#financial_block').hide();
  $('#tila_block').hide();
  $('#summary_block').show();
  $('#factor_trust_block').hide();
  $('#logs_block').hide();
  $('#comments_block').hide();
  $('#documents_block').hide();

  $('#verify_button').hide();
  $('#verify_button_f').hide();
  $('#verify_tila_button').hide();

  document.getElementById('disclosed_finance_charge_amount').focus();
  document.getElementById("employment_link").className="";
  document.getElementById("personal_link").className="";
  document.getElementById("financial_link").className="";
  document.getElementById("tila_link").className="";
  document.getElementById("summary_link").className="content-box-tabs default-tab current";
  //document.getElementById("summary_reject_link").className="";
  document.getElementById("factor_trust_link").className="";
  document.getElementById("comments_link").className="";
  document.getElementById("logs_link").className="";
  document.getElementById("documents_link").className="";

  $('#accept_paragraph').hide();
      $('#accept_reject_container').removeClass('attention').removeClass('success').addClass('error');
      $('#accept_reject_container').show();
}

function callback(hash) {
  if (hash) {
    $("a[rel*='history']").removeClass('current');
    $("a[href='#" + hash + "']").addClass('current');
    $("div[class='content-box']>div[class='content-box-content']").children().hide();
    $("#" + hash).show();
  }
}

function blockEnter(evt) {
  evt = (evt) ? evt : event;
  var charCode = (evt.charCode) ? evt.charCode :
    ((evt.which) ? evt.which : evt.keyCode);
  if (charCode == 13)
  {
    return false;
  }
  else
  {
    return true;
  }
}

$(document).ready(function() {


  // $.history.init(callback);
  // $("a[rel*='history']").click(function(){
  //   str = window.location.toString();
  //   target_tab = ($(this).attr("href")).replace(/#/, '');
  //   window.location.url = str.replace(/(\?tab=|$)(.*)/, "?tab=" + target_tab);
  //   return false;
  // }); 
  $.ui.dialog.defaults.bgiframe = true;
  $('a[rel*=facebox]').facebox();
	$(".dialog").dialog({ autoOpen: false, closeOnEscape: true, width: 800, maxHeight: 300 });
	$(".in_place_editor_field").filter(function() { return $(this).html() == "(Click here to add text)" }).addClass('gray')
  $('img.locked_field').qtip({
     content: 'This can only be updated by an administrator',
     show: 'mouseover',
     hide: 'mouseout',
     style: { name: 'blue', tip: true }
  })
});
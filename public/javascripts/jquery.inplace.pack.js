/*
+-----------------------------------------------------------------------+
| Copyright (c) 2007 David Hauenstein			                        |
| All rights reserved.                                                  |
|                                                                       |
| Redistribution and use in source and binary forms, with or without    |
| modification, are permitted provided that the following conditions    |
| are met:                                                              |
|                                                                       |
| o Redistributions of source code must retain the above copyright      |
|   notice, this list of conditions and the following disclaimer.       |
| o Redistributions in binary form must reproduce the above copyright   |
|   notice, this list of conditions and the following disclaimer in the |
|   documentation and/or other materials provided with the distribution.|
|                                                                       |
| THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS   |
| "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT     |
| LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR |
| A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT  |
| OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, |
| SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT      |
| LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, |
| DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY |
| THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT   |
| (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE |
| OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.  |
|                                                                       |
+-----------------------------------------------------------------------+
*/

jQuery.fn.editInPlace=function(a){var b={url:"",params:"",method:"POST",field_type:"text",select_options:"",textarea_cols:"25",textarea_rows:"10",datepicker:"",bg_over:"#ffc",bg_out:"transparent",saving_text:"Saving...",saving_image:"",default_text:"(Click here to add text)",select_text:"Choose new value",value_required:null,element_id:"element_id",update_value:"update_value",original_html:"original_html",save_button:'<input type="submit" class="inplace_save" value="Save"/>',cancel_button:'<input type="submit" class="inplace_cancel" value="Cancel"/>',callback:null,success:null,error:function(d){alert("Failed to save value: "+d.responseText||"Unspecified Error")}};if(a){jQuery.extend(b,a)}if(b.saving_image!=""){var c=new Image();c.src=b.saving_image}String.prototype.trim=function(){return this.replace(/^\s+/,"").replace(/\s+$/,"")};String.prototype.escape_html=function(){return this.replace(/&/g,"&amp;").replace(/</g,"&lt;").replace(/>/g,"&gt;").replace(/"/g,"&quot;")};return this.each(function(){if(jQuery(this).html()==""){jQuery(this).html(b.default_text)}var d=false;var e=jQuery(this);var f=0;jQuery(this).mouseover(function(){jQuery(this).css("background",b.bg_over)}).mouseout(function(){jQuery(this).css("background",b.bg_out)}).click(function(){f++;if(!d){d=true;var h=jQuery(this).html();var g=b.save_button+" "+b.cancel_button;if(h==b.default_text){jQuery(this).html("")}if(b.field_type=="textarea"){var n='<textarea name="inplace_value" class="inplace_field" rows="'+b.textarea_rows+'" cols="'+b.textarea_cols+'">'+jQuery(this).text().trim().escape_html()+"</textarea>"}else{if(b.field_type=="text"){var n='<input type="text" id="inplace_field" name="inplace_value" class="inplace_field" value="'+jQuery(this).text().trim().escape_html()+'" />'}else{if(b.field_type=="select"){var j=b.select_options.split(",");var n='<select name="inplace_value" class="inplace_field"><option value="">'+b.select_text+"</option>";for(var k=0;k<j.length;k++){var m=j[k].split(":");var o=m[1]||m[0];var l=o==h?'selected="selected" ':"";n+="<option "+l+'value="'+o.trim().escape_html()+'">'+m[0].trim().escape_html()+"</option>"}n+="</select>"}}}jQuery(this).html('<form class="inplace_form" style="display: inline; margin: 0; padding: 0;">'+n+" "+g+"</form>");if(b.datepicker=="datepicker"){$("#inplace_field").datepicker({yearRange:"1900:2007",dateFormat:"MM d, yy",defaultDate:new Date(1980,1-1,1)})}}if(f==1){e.children("form").children(".inplace_field").focus().select();$(document).keyup(function(i){if(i.keyCode==27){d=false;f=0;e.css("background",b.bg_out);e.html(h);return false}});e.children("form").children(".inplace_cancel").click(function(){d=false;f=0;e.css("background",b.bg_out);e.html(h);return false});e.children("form").children(".inplace_save").click(function(){e.css("background",b.bg_out);var p=jQuery(this).parent().children(0).val();if(b.saving_image!=""){var i='<img src="'+b.saving_image+'" alt="Saving..." />'}else{var i=b.saving_text}e.html(i);if(b.params!=""){b.params="&"+b.params}if(b.callback){html=b.callback(e.attr("id"),p,h,b.params);d=false;f=0;if(html){e.html(html||p)}else{alert("Failed to save value: "+p);e.html(h)}}else{if(b.value_required&&p==""){d=false;f=0;e.html(h);alert("Error: You must enter a value to save this field")}else{jQuery.ajax({url:b.url,type:b.method,data:b.update_value+"="+encodeURIComponent(p)+"&"+b.element_id+"="+e.attr("id")+b.params+"&"+b.original_html+"="+h,dataType:"html",complete:function(q){d=false;f=0},success:function(r){var q=r||b.default_text;e.html(q);if(b.success){b.success(r,e)}},error:function(q){e.html(h);if(b.error){b.error(q,e)}}})}}return false})}})})};
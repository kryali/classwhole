$(document).ready(function() {
	$('#add_class_button').click( function(event) {
    mpq.track("Added class from catalog");
												var class_id = $(this).find(".id").text();			                     
												 $.ajax({
		                    		type: 'POST',
		                    		data: { id: class_id },
		                    		url:  '/user/courses/new',
														success: function( data, textStatus, xqHR ) {
															//console.log( data );
															pop_alert(data.status, data.message);
															$("#add_class_button").addClass("disabled");
															$("#add_class_button").removeClass("success");	
															$("#add_class_button .font").text("Class Added");
															$("#add_class_button").unbind( "click" );
														}
		                  		});

	});
});

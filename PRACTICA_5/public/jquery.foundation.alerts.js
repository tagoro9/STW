$(document).on("click", ".alert-box a.close", function (e) {
	e.preventDefault();
	$(this).closest(".alert-box").fadeOut(function () {
		$(this).remove();
	});
});

jQuery(document).ready(function($) {
    $("#submenu").hide();
    $(".mtoggle").click(function() {
        $("#submenu").slideToggle();
    });
});
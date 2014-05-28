$(document).ready(function() {

  $('#pages-search-box').keyup(function() {
    var filter = $(this).val().toLowerCase();

    $('#pages-sidebar li').each(function() {
      var text = $(this).text().toLowerCase();

      if (text.match(filter)) {
        $(this).show()
      } else {
        $(this).hide();
      }
    });
  });

});

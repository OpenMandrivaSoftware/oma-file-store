//= require plupload
//= require_self

$(function() {
  $("#file_store_uploader").pluploadQueue({
    runtime: "html5,html4",
    multiple_queues: true,
    url: "/api/v1/upload",
    file_data_name: 'file_store[file]'
  });
});

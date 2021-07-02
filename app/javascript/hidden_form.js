const hiddenForm = () => {
  var button = document.getElementById('search-btn')
  var hidden_form = document.getElementById('hidden-form')
  button.onsubmit = hidden_form.submit;
};

hiddenForm();

const hideAlgolia = () => {
  var input = document.getElementById('address_address')
  input.onblur = closeSuggest;
  input.onclick = openSuggest;
  input.onfocus = openSuggest;
  function closeSuggest() {
    document.getElementById('algolia-places-listbox-0').style.display = "none";
  }
  function openSuggest() {
    document.getElementById('algolia-places-listbox-0').style.display = "block";
  }
};

export { hideAlgolia };

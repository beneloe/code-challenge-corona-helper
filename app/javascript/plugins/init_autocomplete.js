import places from 'places.js';

const initAutocomplete = () => {
  const reconfigurableOptions = {
    language: 'de',
    countries: ['de'],
    type: 'city',
  };

  const addressInput = document.querySelector('.address-input');
  if (addressInput) {
    places({ container: addressInput }).configure(reconfigurableOptions);
  }
};

export { initAutocomplete };

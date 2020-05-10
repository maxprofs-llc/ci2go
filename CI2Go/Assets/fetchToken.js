(deviceName => {
    let csrfToken;
  fetch('https://circleci.com/api/v2/csrf', {credentials: 'include'})
    .then(r => r.json())
    .then(json => {
      csrfToken = json.csrf_token;
      return fetch('https://circleci.com/api/v1/user/token', {
        credentials: 'include',
        headers: {
          'x-csrftoken': csrfToken
        }
      })
    })
    .then(r => r.json())
    .then(json => {
      if (json && json.message) {
        throw new Error(json.message);
      }
      var labels = json.map(o => o.label),
        prefix = 'Generated by CI2Go on ' + deviceName;
      (label = prefix), (i = 0);
      while (labels.indexOf(label) >= 0) {
        label = prefix + ' ' + ++i;
      }
      return label;
    })
    .then(label =>
      fetch('https://circleci.com/api/v1/user/token', {
        method: 'POST',
        body: JSON.stringify({label}),
        credentials: 'include',
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'X-CSRFToken': csrfToken,
        },
      }),
    )
    .then(r => r.json())
    .then(json => json.token)
    .then(
      token => (document.location.href = 'ci2go://ci2go.app/token/' + token),
    )
    .catch(
      e =>
        (document.location.href =
          'ci2go://ci2go.app/error/' + encodeURIComponent(e.message)),
    );
  return 'OK';
})

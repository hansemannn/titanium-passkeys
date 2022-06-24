# Titanium iOS 16+ PassKeys

Use the iOS 16+ PassKeys APIs in Titanium!

## Requirements

- [x] Xcode 14+
- [x] iOS 16+
- [x] A server to generate the challenge used to authenticate
- [x] Proper [AASA setup](https://blog.branch.io/what-is-an-aasa-apple-app-site-association-file) for your domain, e.g.:
```json
{
  "webcredentials": {
    "apps": [ "A1B2C3D4E5.com.example.app" ]
  }
}

## Example

```js
import PassKeys from 'ti.passkeys';

PassKeys.addEventListener('complete', event => {
  console.warn(event);

  if (event.type === 'registration') {
    // handle registration
  } else {
    // handle assertion
  }
});

PassKeys.addEventListener('error', event => {
  console.error(event.error);
});

PassKeys.performAutoFillAssistedRequests({
  challenge: 'YOUR_SERVER_CHALLENGE',
  relyingPartyIdentifier: 'example.com' // should match your ASSA setup
});
```

## Author

Hans Knöchel

## License

MIT

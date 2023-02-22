## [Unreleased]

## [0.2.1] - 2023-02-22

- [FIX] Correctly set the response body on authentication failure when `on_authentication_failed` is set but `render` is not called from inside the block.

## [0.2.0] - 2023-02-22

- [NEW] Changed the way response status is set on authentication failure, which now gives more controll over response status when using `on_authentication_failed` helper.
- [NEW] Better default response body on authentication failure.

## [0.1.0] - 2023-02-22

- Initial release

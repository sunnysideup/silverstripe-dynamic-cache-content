# td;dr

How this work...

## server side

1. Identify any personalised data in your html templates. If it is specific to that page - then dont cache the page. If it is not specific to the page, then follow below....

2. wrap personalised data in your templates into a function called `PersonalisedData` that knows the selector
of the placeholder and the html for the specific user.

3. there is a url `/my-personalised` - this function returns personalised json for the site with a hash.

#### basic example

```php

<?php
$secretKey = 'your-secret-server-key';

// Function to create HMAC hash
function generateHmac($data, $key) {
    return hash_hmac('sha256', json_encode($data), $key);
}

// Example dynamic content
$data = [
    ['selector' => '#element1', 'html' => '<p>Updated content</p>'],
    ['selector' => '.some-class', 'html' => '<div>New block</div>']
];

$hmac = generateHmac($data, $secretKey);

header('Content-Type: application/json');
echo json_encode([
    'data' => $data, 
    'hmac' => $hmac
]);


```

## client side

4. on load of any page we include a 'hash'.  If that hash is present, client side will compare that `hash` against the hash already in local storage.

5. if it does not match, it goes to the server and picks up the new personalised data, applies and saves it to local storage.

6. if the hash matches, there is nothing is worry about. if it does not match, the content is picked up from the server.

7. Happy life!


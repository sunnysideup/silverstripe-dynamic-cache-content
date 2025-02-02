<script>
async function SiteWideDataProviderServerResponse() {
  const response = await fetch('/graphql-site-wide-data', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
body: JSON.stringify({
  query: `
    query {
      siteWideUniversalData
      siteWidePersonalisedData
    }
  `
})
  });
  const result = await response.json();
  // console.log(result);
  return {
    ...result.data.siteWideUniversalData,
    ...result.data.siteWidePersonalisedData
  };
}

// Start fetching right away
const SiteWideDataProviderServerPromise = SiteWideDataProviderServerResponse();

document.addEventListener('DOMContentLoaded', async () => {
  const storageKey = 'SiteWideDataProvider';
  const originalValues = new Map();

  // Load local data
  let localData = localStorage.getItem(storageKey);
  localData = localData ? JSON.parse(localData) : {};
  // console.log(localData);
  // Store original text + apply local data
  Object.entries(localData).forEach(([selector, value]) => {
    document.querySelectorAll(selector).forEach(el => {
      if (!originalValues.has(selector)) {
        originalValues.set(selector, el.innerHTML);
      }
      el.innerHTML = value;
    });
  });

  // Wait for server data
  const serverData = await SiteWideDataProviderServerPromise;
  // console.log(serverData);
  // Update DOM if server data differs
  Object.entries(serverData).forEach(([selector, value]) => {
    if (localData[selector] !== value) {
      document.querySelectorAll(selector).forEach(el => el.innerHTML = value);
    }
  });

  // Revert local keys not in server data
  Object.keys(localData).forEach(selector => {
    if (!(selector in serverData)) {
      document.querySelectorAll(selector).forEach(el =>
        el.innerHTML = originalValues.get(selector)
      );
    }
  });

  // Store new server data
  localStorage.setItem(storageKey, JSON.stringify(serverData));
});
</script>

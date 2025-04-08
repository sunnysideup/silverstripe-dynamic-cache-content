// This script is designed to be included in a SilverStripe template.'
const dynamicCacheContent = providedPersonalData => {
  // Determine if local storage should be reset
  const urlParams = new URLSearchParams(window.location.search)
  const RESET = urlParams.has('flush') || window.IsFlush === 'true'

  // Key used for storing site-wide universal data in local storage
  const UNIVERSAL_STORAGE_KEY = 'SiteWideUniversalData'

  // Cache duration: 1 hour
  const ONE_HOUR = 3600000

  // Clears local storage if RESET is true
  if (RESET) {
    localStorage.removeItem(UNIVERSAL_STORAGE_KEY)
  }

  /**
   * Retrieves cached universal data from local storage if it's still valid.
   * @returns {object|undefined} Cached data or undefined if expired/missing.
   */
  const getCachedUniversalData = () => {
    try {
      const stored = localStorage.getItem(UNIVERSAL_STORAGE_KEY)
      if (stored) {
        const { data, timestamp } = JSON.parse(stored)
        if (Date.now() - timestamp < ONE_HOUR) return data
      }
    } catch {}
    return undefined
  }

  /**
   * Stores universal data in local storage with a timestamp.
   * @param {object} data - The universal data to cache.
   */
  const setCachedUniversalData = data => {
    localStorage.setItem(
      UNIVERSAL_STORAGE_KEY,
      JSON.stringify({ data, timestamp: Date.now() })
    )
  }

  /**
   * Fetches site-wide data from the GraphQL API.
   * @param {number} pageId - The current page's ID.
   * @param {object} otherData - Additional data for the request.
   * @returns {Promise<object>} Fetched universal and personalized data.
   */
  const fetchSiteWideData = async (pageId, action, id, otherId = {}) => {
    if (!pageId) throw new Error('Page ID is required')

    let universalData = getCachedUniversalData()

    // Construct GraphQL query dynamically
    const queryFields = []
    if (universalData === undefined) {
      queryFields.push(
        'siteWideUniversalData(pageId: $pageId, action: $action, id: $id, otherId: $otherId)'
      )
    }
    queryFields.push(
      'siteWidePersonalisedData(pageId: $pageId, action: $action, id: $id, otherId: $otherId)'
    )

    const query = `
    query SiteWideData(\$pageId: Int, \$action: String,\$id: Int, \$otherId: String) {
      ${queryFields.join(' ')}
    }`

    const variables = {
      pageId: Number(pageId),
      action: String(action),
      id: Number(id),
      otherId: String(otherId)
    }

    // Fetch data from API
    return fetch('/graphql-site-wide-data', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ query, variables })
    })
      .then(response => response.json())
      .then(result => {
        if (!result.data) throw new Error('Invalid GraphQL response')

        // Cache universal data if it's newly fetched
        if (universalData === undefined && result.data.siteWideUniversalData) {
          universalData = result.data.siteWideUniversalData
          setCachedUniversalData(universalData)
        }

        return {
          universal: universalData,
          personalised: result.data.siteWidePersonalisedData
        }
      })
  }

  /**
   * Applies fetched data to DOM elements matching a selector.
   * @param {string} selector - CSS selector for target elements.
   * @param {object} values - Data to apply (e.g., class, HTML content, callback function).
   */
  const applyData = (selector, values) => {
    document.querySelectorAll(selector).forEach(el => {
      if (values.class && !el.classList.contains(values.class)) {
        el.classList.add(values.class)
      }
      if (values.removeClass && el.classList.contains(values.removeClass)) {
        el.classList.remove(values.removeClass)
      }
      if (values.html && el.innerHTML !== values.html) {
        el.innerHTML = values.html
      }
      if (values.prepend && !el.innerHTML.includes(values.prepend)) {
        el.innerHTML = values.prepend + el.innerHTML
      }
      if (values.append && !el.innerHTML.includes(values.append)) {
        el.innerHTML = el.innerHTML + values.append
      }
      if (values.callback) {
        values.callback(el)
      }
    })
  }

  // Retrieve cached universal data and apply it immediately to prevent layout shift
  const cachedUniversal = getCachedUniversalData()
  if (cachedUniversal) {
    Object.entries(cachedUniversal).forEach(([selector, values]) => {
      applyData(selector, values)
    })
  }
  // run the provided personal data
  if (providedPersonalData) {
    Object.entries(providedPersonalData).forEach(([selector, values]) => {
      applyData(selector, values)
    })
  }
  if (providedPersonalData && cachedUniversal) {
    return
  }

  // Begin fetching site-wide data asynchronously
  ;(async () => {
    const { universal, personalised } = await fetchSiteWideData(
      ...[
        '$ID',
        '$ActionForDynamicCaching',
        '$IDForDynamicCaching',
        '$OtherIDForDynamicCaching'
        // $OtherVarsForDynamicCachingAsJson.RAW
      ]
    )

    // Apply universal data if not already applied from cache
    if (!cachedUniversal && universal) {
      requestAnimationFrame(() => {
        Object.entries(universal).forEach(([selector, values]) => {
          applyData(selector, values)
        })
      })
    }

    // Apply personalized data
    if (!providedPersonalData && personalised) {
      requestAnimationFrame(() => {
        Object.entries(personalised).forEach(([selector, values]) => {
          applyData(selector, values)
        })
      })
    }
  })()
}
dynamicCacheContent(null)

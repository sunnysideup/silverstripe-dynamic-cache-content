;(() => {
  // Determine if local storage should be reset
  const urlParams = new URLSearchParams(window.location.search)
  const RESET = urlParams.has('flush') || '$IsFlush' === 'true'

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
   * @param {string} pageId - The current page's ID.
   * @returns {Promise<object>} Fetched universal and personalized data.
   */
  const fetchSiteWideData = async pageId => {
    if (!pageId) throw new Error('Page ID is required')

    let universalData = getCachedUniversalData()

    // Build the GraphQL query dynamically
    const queryStart = 'query{ '
    const pageIdString = `(pageId: ${pageId}) `
    const queryEnd = ' } '
    const query =
      universalData === undefined
        ? queryStart +
          'siteWideUniversalData' +
          pageIdString +
          ' siteWidePersonalisedData' +
          pageIdString +
          queryEnd
        : queryStart + 'siteWidePersonalisedData' + pageIdString + queryEnd

    // Fetch data from API
    return fetch('/graphql-site-wide-data', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ query })
    })
      .then(response => response.json())
      .then(result => {
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
   * @param {boolean} [runCallback=false] - Whether to execute the callback.
   */
  const applyData = (selector, values, runCallback = false) => {
    requestAnimationFrame(() => {
      document.querySelectorAll(selector).forEach(el => {
        if (values.class && !el.classList.contains(values.class)) {
          el.classList.add(values.class)
        }
        if (values.html && el.innerHTML !== values.html) {
          el.innerHTML = values.html
        }
        if (runCallback && values.callback) {
          values.callback(el)
        }
      })
    })
  }

  // Retrieve cached universal data and apply it immediately to prevent layout shift
  const cachedUniversal = getCachedUniversalData()
  if (cachedUniversal) {
    Object.entries(cachedUniversal).forEach(([selector, values]) => {
      applyData(selector, values)
    })
  }

  // Begin fetching site-wide data asynchronously
  ;(async () => {
    const { universal, personalised } = await fetchSiteWideData('$ID')

    // Apply universal data if not already applied from cache
    if (!cachedUniversal && universal) {
      Object.entries(universal).forEach(([selector, values]) => {
        applyData(selector, values)
      })
    }

    // Apply personalized data
    if (personalised) {
      Object.entries(personalised).forEach(([selector, values]) => {
        applyData(selector, values, true)
      })
    }
  })()
})()

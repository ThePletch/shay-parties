export async function withFetchProgressIndicator<T>(wrapped: () => Promise<T>) {
    // don't show the spinner until half a second has passed to avoid flashing the spinner on screen.
    const fetchSpinnerTimeout = setTimeout(() => $("#fetch-in-progress").show(), 500);
    try {
      $("#fetch-error").hide();
      return await wrapped();
    } catch (e) {
      $("#fetch-error").show();
      throw e;
    } finally {
      clearTimeout(fetchSpinnerTimeout);
      $("#fetch-in-progress").hide();
    }
  }
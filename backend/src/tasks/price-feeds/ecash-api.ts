import { query } from '../../utils/axios-query';
import priceUpdater, { PriceFeed, PriceHistory } from '../price-updater';

// ECX/USD from ecash.com (ecash.price.v1.PriceService, REST aliases).
class EcashApi implements PriceFeed {
  public name: string = 'eCash';
  public currencies: string[] = ['USD'];

  public url: string = 'https://dev.ecash.com/price';
  public urlHist: string = 'https://dev.ecash.com/price/history?interval=INTERVAL_1H&page_size=1000&start_time=2026-10-12T00:00:00Z';

  /** @asyncUnsafe */
  public async $fetchPrice(currency): Promise<number> {
    const response = await query(this.url);
    if (response && response['currency'] === currency && response['price'] > 0) {
      return response['price'];
    }
    return -1;
  }

  /**
   * Every hourly candle since the series began. The hourly pass covers the
   * daily one, so 'day' returns nothing.
   *
   * @asyncUnsafe
   */
  public async $fetchRecentPrice(currencies: string[], type: 'hour' | 'day'): Promise<PriceHistory> {
    const priceHistory: PriceHistory = {};
    if (type !== 'hour' || !currencies.includes('USD')) {
      return priceHistory;
    }

    let pageToken = '';
    do {
      const response = await query(this.urlHist + (pageToken ? `&page_token=${encodeURIComponent(pageToken)}` : ''));
      if (!response || !Array.isArray(response['candles'])) {
        break;
      }
      for (const candle of response['candles']) {
        // Live snapshots are saved at the top of the hour, so the hour's
        // opening price is the matching value.
        const time = Date.parse(candle['openTime']) / 1000;
        if (time > 0 && candle['open'] > 0) {
          priceHistory[time] = priceUpdater.getEmptyPricesObj();
          priceHistory[time]['USD'] = candle['open'];
        }
      }
      pageToken = response['nextPageToken'] || '';
    } while (pageToken);

    return priceHistory;
  }
}

export default EcashApi;

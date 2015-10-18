class BitcoreExt
  sign_and_broadcast: (message, utxos, callback) ->

    # tools
    does_include = (array, element) ->
      # TODO

    is_empty = (val) ->
      !val || val == ""

    console.log "sign and broadcast"
    tx_amount = 1000

    console.log "utxo_count", utxos.length
    utxos_out = []
    total_amount_sathoshis = 0

    utxos.each do |utxo|
      amount_satoshis = utxo.value
      total_amount_sathoshis += amount_satoshis
      amount_btc = new bitcore.Unit.fromSatoshis(amount_satoshis).BTC
      console.log amount_btc
      tx_id = utxo.tx_hash_big_endian

      if store.utxos && does_include(JSON.parse(store.utxos), tx_id)
        console.log "skipping transaction: #{tx_id}"
        next
      utxos_out.push
        address:      @address
        txId:         tx_id
        scriptPubKey: utxo.script
        amount:       amount_btc
        vout:         utxo.tx_output_n

      break if amount_satoshis > TX_FEE+tx_amount

    console.log "utxos_out:",  utxos_out.size

    unless is_empty(utxos)
      fee = TX_FEE # from 5000 it should be a good fee
      utxos_out = utxos_out.to_n
      address = @address
      amount  = tx_amount
      pvt_key = @pvt_key_string
      console.log "utxos_out: ", utxos_out

      transaction = `new bitcore.Transaction()
        .from(utxos_out)
        .to(address, amount)
        .change(address)
        .fee(fee)
        .addData(message)
        .sign(pvt_key)`

      tx_hash = `transaction.serialize()`
      console.log tx_hash

      Blockchain.pushtx tx_hash, self.pushtx_callback(utxos_out, callback)

      # TODO:
      #
      # try {
      #
      #   txHash = transaction.serialize();
      # } catch(error) {
      #
      #   reject({
      #     'message': 'Error serializing the transaction: ' + error.message
      #   });
      # }
    else
      console.log "ERROR: Not enough UTXOs"
    end

    console.log "END"
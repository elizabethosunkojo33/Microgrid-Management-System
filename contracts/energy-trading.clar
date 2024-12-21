;; Energy Trading Contract

(define-data-var energy-price uint u100)  ;; Price in STX per kWh * 100

(define-map energy-balances
  principal
  { produced: uint, consumed: uint }
)

(define-public (register-prosumer)
  (begin
    (map-set energy-balances tx-sender { produced: u0, consumed: u0 })
    (ok true)
  )
)

(define-public (record-energy-production (amount uint))
  (let
    (
      (current-balance (default-to { produced: u0, consumed: u0 } (map-get? energy-balances tx-sender)))
    )
    (map-set energy-balances
      tx-sender
      (merge current-balance { produced: (+ (get produced current-balance) amount) })
    )
    (ok true)
  )
)

(define-public (record-energy-consumption (amount uint))
  (let
    (
      (current-balance (default-to { produced: u0, consumed: u0 } (map-get? energy-balances tx-sender)))
    )
    (map-set energy-balances
      tx-sender
      (merge current-balance { consumed: (+ (get consumed current-balance) amount) })
    )
    (ok true)
  )
)

(define-public (settle-energy-balance)
  (let
    (
      (balance (unwrap! (map-get? energy-balances tx-sender) (err u404)))
      (produced (get produced balance))
      (consumed (get consumed balance))
      (price (var-get energy-price))
    )
    (if (> produced consumed)
      (let
        (
          (surplus (- produced consumed))
          (payment (* surplus price))
        )
        (try! (as-contract (stx-transfer? payment tx-sender (as-contract tx-sender))))
        (map-set energy-balances tx-sender { produced: u0, consumed: u0 })
        (ok true)
      )
      (let
        (
          (deficit (- consumed produced))
          (payment (* deficit price))
        )
        (try! (stx-transfer? payment tx-sender (as-contract tx-sender)))
        (map-set energy-balances tx-sender { produced: u0, consumed: u0 })
        (ok true)
      )
    )
  )
)

(define-read-only (get-energy-balance (user principal))
  (map-get? energy-balances user)
)

(define-public (update-energy-price (new-price uint))
  (begin
    (var-set energy-price new-price)
    (ok true)
  )
)


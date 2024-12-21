;; Load Balancing Contract

(define-map grid-load
  uint  ;; timestamp (in hours since epoch)
  { total-consumption: uint, total-production: uint }
)

(define-public (update-grid-load (timestamp uint) (consumption uint) (production uint))
  (let
    (
      (current-load (default-to { total-consumption: u0, total-production: u0 } (map-get? grid-load timestamp)))
    )
    (map-set grid-load
      timestamp
      {
        total-consumption: (+ (get total-consumption current-load) consumption),
        total-production: (+ (get total-production current-load) production)
      }
    )
    (ok true)
  )
)

(define-read-only (get-grid-load (timestamp uint))
  (map-get? grid-load timestamp)
)

(define-public (trigger-demand-response (timestamp uint) (threshold uint))
  (let
    (
      (current-load (unwrap! (map-get? grid-load timestamp) (err u404)))
      (consumption (get total-consumption current-load))
      (production (get total-production current-load))
    )
    (if (> consumption (+ production threshold))
      (begin
        (print "Demand response triggered")
        (ok true)
      )
      (ok false)
    )
  )
)


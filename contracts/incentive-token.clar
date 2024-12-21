;; Incentive Token Contract

(define-fungible-token energy-saving-token)

(define-public (mint (amount uint) (recipient principal))
  (ft-mint? energy-saving-token amount recipient)
)

(define-public (transfer (amount uint) (sender principal) (recipient principal))
  (ft-transfer? energy-saving-token amount sender recipient)
)

(define-read-only (get-balance (account principal))
  (ft-get-balance energy-saving-token account)
)


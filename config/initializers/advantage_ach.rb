ADVANTAGE_ACH_CONFIG = YAML.load_file("#{RAILS_ROOT}/config/advantage_ach.yml")[RAILS_ENV].symbolize_keys

ADVANTAGE_ACH_RETURN_CODES = {
  'R01' => 'Insufficient Funds',
  'R02' => 'Account Closed',
  'R03' => 'No Account',
  'R04' => 'Invalid Account',
  'R06' => 'ODFI Requests return',
  'R07' => 'Revoked Authorization',
  'R08' => 'Stop Payment',
  'R09' => 'Uncollected Funds',
  'R10' => 'Advised as Unauthorized',
  'R11' => 'Check Truncation Return',
  'R12' => 'Account at Other Branch',
  'R13' => 'RDFI Not Qualified to Participate',
  'R14' => 'Death of Representative Payee',
  'R15' => 'Death of Beneficiary of Account Holder',
  'R16' => 'Account Frozen'
}

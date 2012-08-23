raise 'failed' if $should_be_called_only_once
$should_be_called_only_once = true

require 'non_existing_file'
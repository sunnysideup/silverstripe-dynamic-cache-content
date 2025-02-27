<?php

namespace Sunnysideup\DynamicCacheContent\Extensions;

use SilverStripe\Core\Extension;

class DynamicCacheContentExtension extends Extension
{
    public function IsFlush(): string
    {
        $owner = $this->getOwner();
        return $owner->request->getVar('flush') ? 'true' : '';
    }
}

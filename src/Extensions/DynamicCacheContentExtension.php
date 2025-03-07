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

    public function ActionForDynamicCaching(): string
    {
        $owner = $this->getOwner();
        return $owner->request->param('Actions') ?: '';
    }

    public function IDForDynamicCaching(): int
    {
        $owner = $this->getOwner();
        return $owner->request->param('ID') ?: 0;
    }

    public function OtherIDForDynamicCaching(): string
    {
        $owner = $this->getOwner();
        return $owner->request->param('OtherID') ?: '';
    }

    // public function OtherVarsForDynamicCachingAsJson(): string
    // {
    //     $owner = $this->getOwner();
    //     return json_encode([]);
    // }
}

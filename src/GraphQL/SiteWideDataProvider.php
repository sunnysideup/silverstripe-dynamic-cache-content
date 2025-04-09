<?php

namespace Sunnysideup\DynamicCacheContent\GraphQL;

use SilverStripe\Core\ClassInfo;
use SilverStripe\ORM\ArrayList;
use SilverStripe\View\ArrayData;
use Sunnysideup\DynamicCacheContent\Interfaces\SiteWideDataProviderInterface;

class SiteWideDataProvider
{
    public static function resolvePersonalisedData(
        mixed $obj,
        array $args,
        array $context,
        mixed $info
    ): string {
        return self::buildData('resolvePersonalisedData', $obj, $args, $context, $info);
    }

    public static function resolveUniversalData(
        mixed $obj,
        array $args,
        array $context,
        mixed $info
    ): string {
        return self::buildData('resolveUniversalData', $obj, $args, $context, $info);
    }

    protected static ?array $siteWideDataClasses = null;

    private static function getSiteWideDataClassesWhoProvide(): array
    {
        if (self::$siteWideDataClasses === null) {
            self::$siteWideDataClasses = ClassInfo::implementorsOf(SiteWideDataProviderInterface::class);
        }
        return self::$siteWideDataClasses;
    }

    private static function buildData(string $method, $obj, array $args, array $context, $info): string
    {
        if (empty($args['pageId'])) {
            throw new \InvalidArgumentException('Page ID is required for personalised data');
        }
        $data = [];
        $classes = self::getSiteWideDataClassesWhoProvide();
        foreach ($classes as $class) {
            $data += $class::{$method}($obj, $args, $context, $info);
        }
        $data = json_encode($data);
        $data = trim(preg_replace('/\s+/', ' ', $data));
        return $data;
    }
}

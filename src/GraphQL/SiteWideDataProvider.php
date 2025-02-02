<?php

namespace Sunnysideup\DynamicCacheContent\GraphQL;

use Sunnysideup\DynamicCacheContent\Interfaces\SiteWideDataProviderInterface;

class SiteWideDataProvider
{
    public static function resolvePersonalisedData(
        mixed $obj,
        array $args,
        array $context,
        mixed $info
    ): array {
        $classes = self::getSiteWideDataClassesWhoProvide();
        $data = [];
        foreach ($classes as $class) {
            $data += $class::resolvePersonalisedData($obj, $args, $context, $info);
        }
        return $data;
    }

    public static function resolveUniversalData(
        mixed $obj,
        array $args,
        array $context,
        mixed $info
    ): array {
        $classes = self::getSiteWideDataClassesWhoProvide();
        $data = [];
        foreach ($classes as $class) {
            $data += $class::resolvePersonalisedData($obj, $args, $context, $info);
        }
        return $data;
    }

    protected static ?array $siteWideDataClasses = null;

    private static function getSiteWideDataClassesWhoProvide(): array
    {
        if (self::$siteWideDataClasses === null) {
            self::$siteWideDataClasses = ClassInfo::implementorsOf(SiteWideDataProviderInterface::class);
        }
        return self::$siteWideDataClasses;
    }
}

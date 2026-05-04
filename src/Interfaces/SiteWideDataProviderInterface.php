<?php

declare(strict_types=1);

namespace Sunnysideup\DynamicCacheContent\Interfaces;

interface SiteWideDataProviderInterface
{
    public static function resolvePersonalisedData(
        mixed $obj,
        array $args,
        array $context,
        mixed $info
    ): array;

    public static function resolveUniversalData(
        mixed $obj,
        array $args,
        array $context,
        mixed $info
    ): array;
}

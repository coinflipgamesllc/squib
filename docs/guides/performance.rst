Asset Caching (Experimental)
============================

Squib now keeps a small in-memory cache of frequently reused assets. The cache
currently powers PNG, SVG, CSV, and XLSX loading inside a single Ruby process.
Cached entries are refreshed automatically when Squib notices that the source
file's modification time has changed, and inline data strings are keyed by a
hash of their contents.

What you need to do
-------------------

Nothing. The cache lives behind the existing public APIs, so current projects
continue to run exactly as before. You do not need to opt in, change config
files, or invalidate anything manually.

Why add a cache with no visible benefit?
----------------------------------------

The cache is a building block for long-lived tooling (`squib --watch` and other
build-server workflows) where Squib will reuse already decoded assets across
multiple runs. Keeping the behaviour consistent today means future versions can
switch to the persistent server with minimal surprises.

Advanced usage
--------------

If you are embedding Squib inside another process and want to experiment, the
cache object is available as ``Squib.asset_cache``. You can swap in your own
implementation (for example, a cache shared across processes) by assigning to
``Squib.asset_cache=``. This hook is considered experimental and may evolve as
the watch server work progresses.


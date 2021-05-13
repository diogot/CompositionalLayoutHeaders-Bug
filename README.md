# CompositionalLayoutHeaders-Bug
tvOS: Compositional layout bug when using headers

A UICollectionViewCompositionalLayout layout with 4 rows and a boundary supplementary item (used as section title), when the collection view is ~half of the screen (collection view controller nested in another view controller), don’t show the first row correctly when there is a section tittle, but works if the supplementary view have height 0.

In this scenario auto sizing don’t work for the items, there is no warnings and the only workaround is to have hight in the group size limited to a value (that depends on all other collection view sizes). To test this change `CollectionViewController.swift:113`.

This can be observed in the attached project:

When the app is opened there is one section without title and the layout is correct.
Clicking in the cell index 1 loads the snapshot with 1 section with title and the layout scrolls up hiding a third of the first row.
Clicking in the cell index 0 loads the initial snapshot and the layout is correctly again.
The same wrong behavior happens when there is more than one section with title (click on cell index 2 to show with 2 sections).

I’ve disabled `contentInsetAdjustmentBehavior` and set `contentInsetsReference` to none to avoid changes from the framework. Enabling them had different (undesired) side effects.

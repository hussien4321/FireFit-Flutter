import 'package:flutter/material.dart';
import 'package:front_end/helper_widgets.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:country_code_picker/selection_dialog.dart';
import 'package:helpers/helpers.dart';
import 'package:middleware/middleware.dart';
import 'dart:async';

class FiltersDialog extends StatefulWidget {

  static Future<void> launch(BuildContext context, {OutfitFilters filters, bool sortByTop, ValueChanged<LoadOutfits> onSearch}) {
    return showDialog(
      context: context,
      builder: (ctx) => FiltersDialog(
        currentFilters: filters,
        currentSortByTop: sortByTop,
        onSearch: onSearch,
      )
    );
  }

  bool currentSortByTop;
  OutfitFilters currentFilters;
  ValueChanged<LoadOutfits> onSearch;

  FiltersDialog({this.currentSortByTop, this.currentFilters, this.onSearch});

  @override
  _FiltersDialogState createState() => _FiltersDialogState();
}

class _FiltersDialogState extends State<FiltersDialog> {

  bool sortByTop = false;
  OutfitFilters filters = OutfitFilters();

  @override
  void initState() {
    super.initState();
    filters = widget.currentFilters;
    sortByTop = widget.currentSortByTop;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      elevation: 0,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            'Search Filters',
            style: Theme.of(context).textTheme.title.copyWith(
              color: Colors.black,
              fontWeight: FontWeight.bold
            ),
          ),
          InkWell(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                'Reset',
                style: Theme.of(context).textTheme.subtitle.copyWith(
                  color: Colors.deepOrangeAccent,
                  fontWeight: FontWeight.bold
                ),
              ),
            ),
            onTap: _resetFilters,
          )
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _sortByTab(),
            sortByTop? _dateTab() : Container(),
            _genderTab(),
            _styleTab(),
            _countryTab(),
          ],
        ),
      ),
      actions: <Widget>[
        FlatButton(
          child: Text(
            'Cancel',
            style: Theme.of(context).textTheme.subtitle.copyWith(
              color: Colors.grey,
              fontWeight: FontWeight.bold
            ),
          ),
          onPressed: Navigator.of(context).pop,
        ),
        FlatButton(
          child: Text(
            'Search',
            style: Theme.of(context).textTheme.subtitle.copyWith(
              color: canSearch ? Colors.blue : Colors.grey[700],
              fontWeight: FontWeight.bold
            ),
          ),
          onPressed: _onSearch,
        )
      ],
    );
  }

  _onSearch() {
    widget.onSearch(LoadOutfits(
      filters: filters,
      sortByTop: sortByTop,
    ));
    Navigator.pop(context);
  }

  bool get canSearch => sortByTop != widget.currentSortByTop || filters != widget.currentFilters;

  _resetFilters() {
    setState(() {
      filters = OutfitFilters();
      sortByTop = false;
    });
  }

  Widget _sortByTab(){
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            'Sort by',
            style: Theme.of(context).textTheme.button.apply(color: Colors.grey),
          ),
        ),
        Expanded(
          child: DropdownButton(
            isExpanded: true,
            items: [false, true].map((isSortingByTop) => DropdownMenuItem(
              value: isSortingByTop,
              child: Text(
                isSortingByTop ? 'Top' : 'New',
                style: TextStyle(
                  inherit: true,
                  color: isSortingByTop == false ? Colors.black : Colors.blue
                ),
              ),
            )).toList(),
            value: sortByTop,
            onChanged: (newSortByTop) => setState(() => sortByTop = newSortByTop),
          )
        )
      ],
    );
  }
  Widget _dateTab(){
    List<DateRanges> dateRanges = [null];
    dateRanges..addAll(DateRanges.values);
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            'Date Range',
            style: Theme.of(context).textTheme.button.apply(color: Colors.grey),
          ),
        ),
        Expanded(
          child: DropdownButton(
            isExpanded: true,
            items: dateRanges.map((newDateRange) => DropdownMenuItem(
              value: newDateRange,
              child: Text(
                newDateRange==null ? 'All time' : dateRangeToString(newDateRange),
                style: TextStyle(
                  inherit: true,
                  color: newDateRange == null ? Colors.black : Colors.blue
                ),
              ),
            )).toList(),
            value: filters.dateRange,
            onChanged: (newDateRange) => setState(() => filters.dateRange = newDateRange),
          ),
        )
      ],
    );
  }
  Widget _genderTab(){
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            'Gender',
            style: Theme.of(context).textTheme.button.apply(color: Colors.grey),
          ),
        ),
        Expanded(
          child: DropdownButton(
            isExpanded: true,
            items: [null, false, true].map((newGenderIsMale) => DropdownMenuItem(
              value: newGenderIsMale,
              child: Text(
                newGenderIsMale ==null ? 'Any' : (newGenderIsMale ? 'Male' : 'Female'),
                style: TextStyle(
                  inherit: true,
                  color: newGenderIsMale == null ? Colors.black : Colors.blue
                ),
              ),
            )).toList(),
            value: filters.genderIsMale,
            onChanged: (newGenderIsMale) => setState(() => filters.genderIsMale = newGenderIsMale),
          ),
        )
      ],
    );
  }
  Widget _styleTab(){
    List<Style> styles = [null];
    styles..addAll(ClothesStyles.values.map((styleEnum) => Style(styleEnum)));
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            'Style',
            style: Theme.of(context).textTheme.button.apply(color: Colors.grey),
          ),
        ),
        Expanded(
          child: DropdownButton(
            isExpanded: true,
            items: styles.map((newStyle) => DropdownMenuItem(
              value: newStyle == null ? null : newStyle.name.toLowerCase(),
              child: Text(
                newStyle == null ? 'Any' : newStyle.name,
                style: TextStyle(
                  inherit: true,
                  color: newStyle == null ? Colors.black : Colors.blue
                ),
              ),
            )).toList(),
            value: filters.style,
            onChanged: (newStyle) => setState(() => filters.style = newStyle),
          ),
        )
      ],
    );
  }
  Widget _countryTab(){
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            'Country',
            style: Theme.of(context).textTheme.button.apply(color: Colors.grey),
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTap: _selectCountry,
            child: Container(
              padding: EdgeInsets.only(right: 2, bottom: 4),
              margin: EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                border: BorderDirectional(
                  bottom: BorderSide(
                    width: 0.5,
                    color: Colors.grey.withOpacity(0.5), 
                  )
                )
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  filters.countryCode == null ? Text(
                    'Any'
                  ) : CountrySticker(
                    countryCode: filters.countryCode,
                    color: Colors.blue,
                  ),
                  Icon(
                    Icons.arrow_drop_down,
                    size: 24,
                    color: Colors.grey[700],
                  )
                ],
              ),
            ),
          )
        )
      ],
    );
  }

  _selectCountry() async {
    final newCountryCode = await CountryPicker.launch(context);
    if(newCountryCode!=null){
      setState(() {
        filters.countryCode = newCountryCode;
      });
    }
  }
}
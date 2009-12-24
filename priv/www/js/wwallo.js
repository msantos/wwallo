
var wwallo = function() {
    var geo = undefined;
    var radius = '5';
    var units = 'km';
    var search = '';
    var history = '100';
    var significance = 2;

    var pos = undefined;
    var address = undefined;
    var error = undefined;
    var json = {};

    var city = 'In the Mysterious Realm of';
    var country = 'An Unknown Country';

    return {
        'city': function () {
            return city;
        },
        'country': function () {
            return country;
        },
        'error': function (v) {
            return (v ? error = v : error);
        },
        'geo': function (v) {
            return (v ? geo = v : geo);
        },
        'address': function (v) {
            return (v ? address = v : address);
        },
        'json': function (v) {
            return (v ? json = v : json);
        },
        'history': function (v) {
            return (v ? history = parseInt(v) : history);
        },
        'pos': function (v) {
            return (v ? pos = v : pos);
        },
        'radius': function (v) {
            return (v ? radius = parseInt(v) : radius);
        },
        'search': function (v) {
            return (v ? search = v : search);
        },
        'significance': function (v) {
            return (v ? significance = parseInt(v) : significance);
        },
        'units': function (v) {
            return (v ? units = v : units);
        },
    }
}();


function update_position(position) {
    var pos = position.latitude + ',' + position.longitude + ',' + wwallo.radius() + wwallo.units();
    $.getJSON('/geocode/' + pos, function (json) {
            wwallo.json(json);
            wwallo.pos(pos);
            wwallo.address(position.gearsAddress);
            main_screen(json,pos);
            });

}

function noposition(positionError, url) {
    if (positionError)
        wwallo.error(positionError);

    url = (typeof url != 'undefined') ? url : '/geocode/null,' + wwallo.radius() + wwallo.units();
    $.getJSON(url, function (json) {
            wwallo.json(json);
            main_screen(json);
            });
}

function get_position() {
    if (typeof google == 'undefined' || typeof google.gears == 'undefined') {
        noposition();
        return (true);
    }

    var geo = wwallo.geo() || google.gears.factory.create('beta.geolocation');
    wwallo.geo(geo);
    wwallo.error(undefined);
    geo.getCurrentPosition(update_position, noposition, {
                enableHighAccuracy: true,
                gearsRequestAddress: true,
                //timeout: 120,
                //maximumAge: 0,
                }
            );
}

function main_screen(json, pos) {
    var city = json.city || wwallo.city();
    var country = json.country || wwallo.country();
    var loc = city + ', ' + country;

    // Errors are only returned if Gears is not installed or there was a problem
    // with gears.
    var error = (wwallo.error()
            ? '<p><span class="Alert">Geolocation Error:</span>' + wwallo.error().message
            : '');

    if (wwallo.address()) {
    var addr = wwallo.address();

    loc = (addr.streetNumber ? addr.streetNumber + ' ' : '') +
        (addr.street ? addr.street + ', ' : '') +
        (addr.city || city) + ', ' + (addr.country || country);
    }
    $('#location').empty().append(loc);

    if (pos) {
        $('div.menu_help').html('Your location: ' + geofmt(pos) + ' (' + json.address + ')');
    }
    else {
        $('span#menu_help').addClass('Alert');
        $('div.menu_help').html(
            '<p>Your location (guessed from your internet address): ' +
            geofmt(json.pos) + ' (' + json.address + ')</p>' + 
            (error ? error : 
            '<p>To enable your device to provide accurate location data, \
            please install \
            <span class="Gears"> \
            <a href="http://gears.google.com/?action=install">Google Gears</a>.</p> \
            </span>')
            );
    }

    var tags = new Array();
    $.each(json.count, function(key,val) {
        if (val >= wwallo.significance()) {
            //tags.push({ 'tag': key + '(' + val + ')', 'count': val });
            tags.push({ 'tag': key, 'count': val });
        }
            });

    $('#tagcloud').tagCloud(tags, {
            'click': function (tag) {
            display_messages(json, tag);
            }
            });

    $('div#menu').slideDown('slow');
}

function display_messages(json, tag) {
    var re = new RegExp('\\b' + tag, 'i');
    $.each(json.tweet, function(n) {
            if (re.test(json.tweet[n])) {
            var tweet = '<img src="' + json.image[n] + '" class="Profile"/>' +
            '<span class="Author">' + json.author[n] + '</span><br />' +
            '<span class="Message">' + json.tweet[n] + '</span>';

            $.jGrowl(tweet, {
                'sticky': true,
                'closeTemplate': '',
                });
            }
            });
    $('div#tagcloud > a.tagcloudlink').filter(function () {
                    return $(this).text() == tag;
                    }).css('text-decoration', 'line-through');
}


function geofmt(str) {
    var loc = str.split(/,/g);
    return (loc.length == 3
        ? 'Lat: ' + loc[0] + ' Lon: ' + loc[1] + ' Distance: ' + loc[2]
        : str);
}


function refresh_or_redraw(refresh, redraw) {
    var DO_REFRESH = 2;
    var DO_REDRAW = 1;
    var action = 0;

    var v;
    var oval;
    var nval;

    $.each(redraw, function (n) {
            v = redraw[n];
            oval = wwallo[v]();
            nval = $('#' + v).val();
            if (oval != nval) {
            wwallo[v](nval);
            action = DO_REDRAW;
            }
            });

    $.each(refresh, function (n) {
            v = refresh[n];
            oval = wwallo[v]();
            nval = $('#' + v).val();
            if (oval != nval) {
            wwallo[v](nval);
            action = DO_REFRESH;
            }
            });

    switch (action) {
        case DO_REFRESH:
            get_position();
            break;
        case DO_REDRAW:
            main_screen(wwallo.json(), wwallo.pos());
            break;
        default:
            break;
    }
}



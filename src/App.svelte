<!-- 
  # ============================================================================ #
  #  ............... script ...............
-->

<script>
  // # Imports

  // Scrolly stuff
  import { onMount } from 'svelte';
  import Scroller from './layout/Scroller.svelte';
  import {
    Map,
    StaticMap1,
    MapSource,
    MapLayer,
    MapTooltip,
  } from '../libs/@onsvisual/svelte-maps';
  import { getData, getColor, getTopo, getJson } from './utils.js';
  import bbox from '@turf/bbox';

  // Layout
  import { setContext } from 'svelte';
  import { themes } from './config.js';
  import { setColors } from './utils.js';
  import { colors } from './config.js';
  import UHCHeader from './layout/UHCHeader.svelte';
  import UHCFooter from './layout/UHCFooter.svelte';
  import Header from './layout/Header.svelte';
  import Section from './layout/Section.svelte';
  import Media from './layout/Media.svelte';
  import Filler from './layout/Filler.svelte';
  import Divider from './layout/Divider.svelte';
  import Toggle from './ui/Toggle.svelte';
  import Arrow from './ui/Arrow.svelte';
  let theme = 'light';
  setContext('theme', theme);
  setColors(themes, theme);

  // # Map objects

  const hex_primary = '#2F8FBC';
  const hex_secondary = '#00BB9E';
  const hex_error = '#BC3B2F';
  const hex_warning = '#BC812F';

  const bounds = {
    southAmerica: [
      [-117.157278, -55.058347], // Southwest coordinates
      [-66.273339, 34], // Northeast coordinates
    ],
    municipio: [
      [-46.826191, -24.008374],
      [-46.365357, -23.357529],
    ],
    l1ad: [
      [-47.084742, -24.008374],
      [-46.051954, -23.183419],
    ],
  };

  // Bindings
  let map;

  // Data

  // State
  let zoom;
  let center = {};
  let hovered, selected;

  // # ============================================================================ #
  // Import Data

  // All Salurbal L1 centroids
  const src__salurbal_centroid = {
    url: './data/salurbal_l1ad_centroid.json',
    layer: 'geog',
    code: 'salid2',
  };
  let geojson_salurbal_centroid;
  getTopo(src__salurbal_centroid.url, src__salurbal_centroid.layer).then(
    (res) => {
      geojson_salurbal_centroid = res;
    }
  );

  // municipio centroid
  const src__municipio_centroid = {
    url: './data/sao_paolo_municipio_centroid.json',
    layer: 'geog',
    code: 'salid2',
  };
  let geojson_municipio_centroid;
  getTopo(src__municipio_centroid.url, src__municipio_centroid.layer).then(
    (res) => {
      geojson_municipio_centroid = res;
    }
  );

  // L1AD centroid
  let sao_paolo_l1ad_centroid;
  getJson('./data/sao_paolo_l1ad_centroid.json').then((res) => {
    sao_paolo_l1ad_centroid = res;
  });

  // Municipio boundaries
  const src_municipio = {
    url: './data/sao_paolo_municipio.json',
    layer: 'geog',
    code: 'salid2',
  };
  let geojson_municipio;
  getTopo(src_municipio.url, src_municipio.layer).then((res) => {
    geojson_municipio = res;
  });

  // L1UX boundaries
  const src_l1ux = {
    url: './data/sao_paolo_l1ux.json',
    layer: 'geog',
    code: 'salid1',
  };
  let geojson_l1ux;
  getTopo(src_l1ux.url, src_l1ux.layer).then((res) => {
    geojson_l1ux = res;
  });

  // L1AD boundaries
  const src_l1ad = {
    url: './data/sao_paolo_l1ad.json',
    layer: 'geog',
    code: 'salid1',
  };
  let geojson_l1ad;
  getTopo(src_l1ad.url, src_l1ad.layer).then((res) => {
    geojson_l1ad = res;
  });

  // L2 boundaries
  const src_l2 = {
    url: './data/sao_paolo_l2.json',
    layer: 'geog',
    code: 'salid2',
  };
  let geojson_l2;
  getTopo(src_l2.url, src_l2.layer).then((res) => {
    geojson_l2 = res;
  });

  // Functions for map component
  function fitBounds(bounds) {
    if (map) {
      map.fitBounds(bounds, { animate: true, padding: 30 });
    }
  }
  function fitById(id) {
    if (geojson && id) {
      let feature = geojson.features.filter(
        (d) => d.properties.AREANM == id
      )[0];
      let bbox_tmp = bbox(feature.geometry);

      fitBounds(bbox_tmp);
    }
  }

  // # Scroller Setup
  const threshold = 0.65;
  let id = {}; // Object to hold visible section IDs of Scroller components
  let idPrev = {}; // Object to keep track of previous IDs, to compare for changes
  onMount(() => {
    idPrev = { ...id };
  });
  function runActions(codes = []) {
    //// Code to run Scroller actions when new caption IDs come into view
    codes.forEach((code) => {
      if (id[code] != idPrev[code]) {
        // if caption id changes then run then run following code to update chart
        if (actions[code][id[code]]) {
          actions[code][id[code]]();
        }
        idPrev[code] = id[code];
      }
    });
  }

  $: {
    // Run above code when 'id' object changes
    if (id) {
      runActions(Object.keys(actions));
    }
  }

  // # ============================================================================ #
  // Scroller Action
  let custom = {
    mapid: 'map01',
    layers: {
      municipio_centroid: {
        'circle-color': hex_error,
        'circle-radius': 8,
        'circle-stroke-color': hex_error,
        'circle-stroke-width': 2,
      },
      municipio: false,
      l1ux: false,
      l2_line: false,
    },
  };
  let actions = {
    map: {
      map01: () => {
        fitBounds(bounds.southAmerica);
        custom = {
          mapid: 'map01',
          layers: {
            municipio_centroid: {
              'circle-color': hex_error,
              'circle-radius': 7,
              'circle-stroke-color': hex_error,
              'circle-stroke-width': 1,
            },
            municipio: false,
            l1ux: false,
            l2_line: false,
          },
        };
      },
      map02: () => {
        fitBounds(bounds.l1ad);
        custom = {
          mapid: 'map02',
          layers: {
            municipio_centroid: false,
            municipio: false,
            l1ux: false,
            l2_line: {
              'line-color': hex_primary,
              'line-width': 5,
            },
          },
        };
      },
      map03: () => {
        fitBounds(bounds.l1ad);
        custom = {
          mapid: 'map03',
          layers: {
            municipio_centroid: false,
            municipio: false,
            l1ux: {
              'line-color': hex_warning,
              'line-width': 8,
            },
            l2_line: {
              'line-color': hex_primary,
              'line-width': 2,
              'line-opacity': 0.75,
            },
          },
        };
      },
      map04: () => {
        fitBounds(bounds.l1ad);
        custom = {
          mapid: 'map04',
          layers: {
            municipio_centroid: false,
            municipio: false,
            l1ux: {
              'line-color': hex_warning,
              'line-width': 5,
            },
            l2_line: {
              'line-color': hex_primary,
              'line-width': 2,
              'line-opacity': 1,
            },
            l2_fill: {
              'fill-color': hex_warning,
              'fill-opacity': 0.5,
            },
          },
        };
      },
      map05: () => {
        fitBounds(bounds.l1ad);
        custom = {
          mapid: 'map05',
          layers: {
            municipio_centroid: false,
            municipio: false,
            l1ux: false,
            l2_line: {
              'line-color': hex_primary,
              'line-width': 2,
              'line-opacity': 1,
            },
            l2_fill: {
              'fill-color': hex_error,
              'fill-opacity': 0.5,
            },
            l1ad_line: {
              'line-color': hex_error,
              'line-width': 5,
            },
          },
        };
      },
    },
  };
</script>

<!-- 
  # ============================================================================ #
  #  ............... markup ...............
-->

<UHCHeader filled={true} center={false} />

<Filler theme="lightblue" short={true} wide={true} center={false}>
  <h1>What is a SALURBAL City?</h1>
  <p class="text-big" style="margin-top: 5px">
    SALURBAL city, sub-city, and neighborhood definition and selection
  </p>

  <p class="text-medium">
    Designed by: <span style={'font-weight: 900'}>
      Usama Bilal, Katie Indvik, Steve Melly, Andrea Bolinaga, Kari Moore, Alex
      Quistberg, Ana V. Diez Roux</span
    >
    <br />
    Engineered by:
    <span style={'font-weight: 900'}> Anuj Tanwar, Ran Li</span>
    <br />
    August 22, 2023
  </p>
</Filler>

<Section>
  <h3>Introduction</h3>
  <p class="text-medium">
    The SALURBAL team has developed a rigorous protocol for defining cities,
    sub-cities, and neighborhoods. This process allows us to study and compare
    urban environments and their health impacts across cities in 11 countries in
    Latin America (Argentina, Brazil, Chile, Colombia, Costa Rica, El Salvador,
    Guatemala, Mexico, Nicaragua, Panama, and Peru).
  </p>
  <p class="text-medium">
    We took several steps to identify and define SALURBAL cities. The approach
    described below has guided the definition of geographic areas to which all
    SALURBAL data is linked. You can read more about this process in “Building a
    Data Platform for Cross-Country Urban Health Studies.”
  </p>
</Section>

<Divider />

<Section>
  <h3>Step 1. Identifying cities with a population of 100,000 or more.</h3>
  <p class="text-medium">
    The SALURBAL city universe was defined as all urban agglomerations with at
    least 100,000 residents as of 2010.
  </p>
  <p class="text-medium">
    We used the Atlas of Urban Expansion and country census data from
    citypopulation.de to obtain a list of all cities (as defined in these
    sources) with 100,000 residents or more in 2010. We combined both lists and
    eliminated overlaps. Cities that were very close together and were therefore
    part of the same urban agglomeration were combined. The name of the largest
    city or a hyphenated name was assigned to that unit. SALURBAL team members
    in each country helped create a final list of 371 cities. We will refer to
    these as “SALURBAL cities.”
  </p>
</Section>

<!-- 
  # ============================================================================ #
  # Map 1  (371 Salurbal cities)
-->

<Media col="medium" caption="Map of all 371 SALURBAL cities">
  <div class="chart-sml">
    <StaticMap1
      id="static_map_1"
      style="./data/style-osm-grey.json"
      location={{ bounds: bounds.southAmerica }}
      controls={false}
      scales={true}
      bind:map
      bind:zoom
      bind:center
    >
      <MapSource
        map_id="static_map_1"
        id="static_map_1-src"
        type="geojson"
        data={geojson_salurbal_centroid}
        promoteId={'salurbal_centroids'}
        maxzoom={13}
      >
        <MapLayer
          map_id="static_map_1"
          id="static_map_1-circle"
          type="circle"
          paint={{
            'circle-color': hex_warning,
            'circle-radius': 3,
            'circle-stroke-color': 'black',
            'circle-stroke-width': 1,
          }}
        />
      </MapSource>
    </StaticMap1>
  </div>
</Media>

<Section>
  <h3>Step 2: Defining the geographic boundaries of each city.</h3>
  <p class="text-medium">
    We operationalized (or geographically defined) each SALURBAL city using
    existing administrative units to which health and other data could be easily
    linked. These administrative units included municipios, departamentos, or
    similar units in each country.
  </p>
</Section>
<div style="height: 3rem" />

<!-- 
  # ============================================================================ #
  # Scrolly 1  (define city boundaries)
-->
<Scroller {threshold} bind:id={id['map']} splitscreen={true}>
  <div slot="background">
    <figure>
      <div class="col-full height-full">
        <Map
          id="scrolly_map_1"
          style="./data/style-esri-world-imagery.json"
          location={{ bounds: bounds.southAmerica }}
          controls={false}
          scales={true}
          bind:map
          bind:zoom
          bind:center
        >
          <MapSource
            map_id="scrolly_map_1"
            id="municipio_centroid"
            type="geojson"
            data={geojson_municipio_centroid}
            promoteId={'municipio_centroid'}
            maxzoom={13}
          >
            <MapLayer
              map_id="scrolly_map_1"
              id="municipio_centroid"
              {custom}
              type="circle"
            />
          </MapSource>
          <MapSource
            map_id="scrolly_map_1"
            id="municipio"
            type="geojson"
            data={geojson_municipio}
            promoteId={src_municipio.code}
            maxzoom={13}
          >
            <MapLayer
              map_id="scrolly_map_1"
              id="municipio"
              {custom}
              type="line"
            />
          </MapSource>

          <MapSource
            map_id="scrolly_map_1"
            id="l2"
            type="geojson"
            data={geojson_l2}
            promoteId={src_l2.code}
            maxzoom={13}
          >
            <MapLayer
              map_id="scrolly_map_1"
              id="l2_line"
              {custom}
              type="line"
            />
            <MapLayer
              map_id="scrolly_map_1"
              id="l2_fill"
              {custom}
              type="fill"
            />
          </MapSource>
          <MapSource
            map_id="scrolly_map_1"
            id="l1ux"
            type="geojson"
            data={geojson_l1ux}
            promoteId={src_l1ux.code}
            maxzoom={13}
          >
            <MapLayer map_id="scrolly_map_1" id="l1ux" {custom} type="line" />
          </MapSource>
          <MapSource
            map_id="scrolly_map_1"
            id="l1ad"
            type="geojson"
            data={geojson_l1ad}
            promoteId={src_l1ad.code}
            maxzoom={13}
          >
            <MapLayer
              map_id="scrolly_map_1"
              id="l1ad_line"
              {custom}
              type="line"
            />
          </MapSource>
        </Map>
        <!-- <div class="stickDev">
          {id.map}
        </div> -->
      </div>
    </figure>
  </div>

  <div slot="foreground">
    <section data-id="map01">
      <div class="col-medium">
        <p><strong>We’ll use São Paulo, Brazil as an example. </strong></p>
      </div>
    </section>
    <section data-id="map02">
      <div class="col-medium">
        <p>
          <strong
            >These are the <span style={`color: ${hex_primary};`}
              >administrative units (municipios)</span
            > around São Paulo, Brazil</strong
          >
        </p>
      </div>
    </section>
    <section data-id="map03">
      <div class="col-medium">
        <p>
          <strong
            >This is the <span style={`color: ${hex_warning};`}
              >urban extent</span
            > or built-up area of São Paulo, Brazil</strong
          >
        </p>
      </div>
    </section>
    <section data-id="map04">
      <div class="col-medium">
        <p>
          <strong
            >Through visual inspection of satellite imagery, we identified <span
              style={`color: ${hex_warning};`}
            >
              all administrative units that included any portion of the built-up
              area</span
            > of each SALURBAL city.</strong
          >
        </p>
      </div>
    </section>
    <section data-id="map05">
      <div class="col-medium">
        <p>
          <strong
            >The combination of these administrative units is considered a
            <span style={`color: ${hex_error};`}>SALURBAL city.</span>
          </strong>
        </p>
      </div>
    </section>
  </div>
</Scroller>

<!-- 
  # ============================================================================ #
  #  ............... style ...............
-->
<style>
  /* Styles specific to elements within the demo */
  :global(svelte-scroller-foreground) {
    pointer-events: none !important;
  }
  :global(svelte-scroller-foreground section div) {
    pointer-events: all !important;
  }
  select {
    max-width: 350px;
  }
  .stickDev {
    position: fixed;
    bottom: 0;
    right: 0;
    background-color: white;
    padding: 10px;
  }
  .chart {
    margin-top: 45px;
    width: calc(100% - 5px);
  }
  .chart-full {
    margin: 0 20px;
  }
  .chart-sml {
    font-size: 0.85em;
    height: 300px;
  }
  /* The properties below make the media DIVs grey, for visual purposes in demo */
  .media {
    background-color: #f0f0f0;
    display: -webkit-box;
    display: -ms-flexbox;
    display: flex;
    -webkit-box-orient: vertical;
    -webkit-box-direction: normal;
    -ms-flex-flow: column;
    flex-flow: column;
    -webkit-box-pack: center;
    -ms-flex-pack: center;
    justify-content: center;
    text-align: center;
    color: #aaa;
  }
</style>

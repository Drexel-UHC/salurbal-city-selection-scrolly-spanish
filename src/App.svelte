<!-- 
  # ============================================================================ #
  #  ............... script ...............
-->

<script>
  // # ============================================================================ #
  import { onMount } from 'svelte';
  import Scroller from './layout/Scroller.svelte';
  import {
    Map,
    MapSource,
    MapLayer,
    MapTooltip,
  } from '../libs/@onsvisual/svelte-maps';
  import { getData, getColor, getTopo, getJson } from './utils.js';
  import bbox from '@turf/bbox';

  // # ============================================================================ #
  // # Map objects

  const colors = {
    seq5: [
      'rgb(234, 236, 177)',
      'rgb(169, 216, 145)',
      'rgb(0, 167, 186)',
      'rgb(0, 78, 166)',
      'rgb(0, 13, 84)',
    ],
    div10: [
      '#67001f',
      '#b2182b',
      '#d6604d',
      '#f4a582',
      '#fddbc7',
      '#d1e5f0',
      '#92c5de',
      '#4393c3',
      '#2166ac',
      '#053061',
    ],
  };

  const bounds = {
    southAmerica: [
      [-81.35, -56.54], // Southwest corner: min longitude, min latitude
      [-32.39, 13.39], // Northeast corner: max longitude, max latitude
    ],
    municipio: [
      [-46.826191, -24.008374],
      [-46.365357, -23.357529],
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
  // # Get Data

  let salurbal_centroids;
  getJson('./data/centroids.json').then((res) => (salurbal_centroids = res));

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

  let sao_paolo_l1ad_centroid;
  getJson('./data/sao_paolo_l1ad_centroid.json').then((res) => {
    sao_paolo_l1ad_centroid = res;
  });

  const src_municipio = {
    url: './data/sao_paolo_municipio.json',
    layer: 'geog',
    code: 'salid2',
  };
  let geojson_municipio;
  getTopo(src_municipio.url, src_municipio.layer).then((res) => {
    geojson_municipio = res;
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

  // # ============================================================================ #
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
  // #### Scroller Action
  let custom = {
    id: 'map01',
    municipio_centroid: true,
    municipio: false,
  };
  let actions = {
    map: {
      map01: () => {
        console.log(`######### map01`);
        fitBounds(bounds.southAmerica);
        custom = {
          id: 'map01',
          municipio_centroid: true,
          municipio: false,
        };
      },
      map02: () => {
        console.log(`######### map02`);
        fitBounds(bounds.municipio);
        custom = {
          id: 'map02',
          municipio_centroid: false,
          municipio: true,
        };
        // boundaries = true;
        // fill = false;
        // highlight = false;
        // stateBoundaries = false;
      },
      // map03: () => {
      //   console.log(`######### map03`);
      //   fitBounds(bounds.southAmerica);
      //   boundaries = false;
      //   fill = true;
      //   colorKey = 'color_age_med';
      //   highlight = true;
      //   stateBoundaries = false;
      // },
      // map04: () => {
      //   console.log(`######### map04`);
      //   fitBounds(bounds.southAmerica);
      //   boundaries = false;
      //   fill = true;
      //   colorKey = 'color_salary';
      //   highlight = true;
      //   stateBoundaries = false;
      // },
      // map05: () => {
      //   console.log(`######### map05`);
      //   fitById('Philadelphia, PA');
      //   boundaries = false;
      //   fill = true;
      //   colorKey = 'color_salary';
      //   highlight = true;
      //   stateBoundaries = false;
      // },
      // map06: () => {
      //   console.log(`######### map06`);
      //   fitBounds(bounds.southAmerica);
      //   boundaries = true;
      //   fill = false;
      //   highlight = false;
      //   stateBoundaries = true;
      // },
    },
  };
</script>

<!-- 
  # ============================================================================ #
  #  ............... scrolly ...............
-->

<Scroller {threshold} bind:id={id['map']} splitscreen={true}>
  <div slot="background">
    <figure>
      <div class="col-full height-full">
        <Map
          id="map"
          style="./data/style-osm.json"
          location={{ bounds: bounds.southAmerica }}
          controls={false}
          scales={true}
          bind:map
          bind:zoom
          bind:center
        >
          <MapSource
            id="municipio_centroid"
            type="geojson"
            data={geojson_municipio_centroid}
            promoteId={'municipio_centroid'}
            maxzoom={13}
          >
            <MapLayer
              id="municipio_centroid"
              {custom}
              type="circle"
              paint={{
                'circle-color': '#00BB9E',
                'circle-radius': 7,
                'circle-stroke-color': '#BC3B2F',
                'circle-stroke-width': 5,
              }}
            />
          </MapSource>
          <MapSource
            id="municipio"
            type="geojson"
            data={geojson_municipio}
            promoteId={src_municipio.code}
            maxzoom={13}
          >
            <MapLayer
              id="municipio"
              {custom}
              type="line"
              paint={{
                'line-color': '#2F8FBC',
                'line-width': 5,
              }}
            />
          </MapSource>
        </Map>
        <div class="stickDev">
          {id.map}
        </div>
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
          <strong>This is the municipio boundaries for São Paulo, Brazil</strong
          >
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

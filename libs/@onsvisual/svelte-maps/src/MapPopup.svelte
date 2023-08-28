<script>
  import { getContext } from 'svelte';
  import mapbox from './lib/mapbox-gl@1.13.2';
  // Mapbox source code is bundled due to versioning & ES6 import issues
  // https://cdn.skypack.dev/-/mapbox-gl@v1.13.2-asizChmwkQobquJNQjgb/dist=es2020,mode=imports,min/optimized/mapbox-gl.js

  export let content;
  export let map_id;
  export let popup_id;
  export let custom;



  const { getMap } = getContext(map_id);
  const map = getMap();

  const popup = new mapbox.Popup({
    closeButton: false,
    closeOnClick: false,
    className: 'sp_popup'
  }).setLngLat([-46.5639571, -22.5779278])
    .setHTML(`São Paulo, Brazil`)
 
  $: {
    console.log(` ----- SP POPUP ----- `)
    console.log(custom.layers.sp_popup)
        if (custom.layers.sp_popup) {
      popup
        .addTo(map);
    } else {
      popup.remove();
    }
  }
 

</script>

<style>
  :global(.sp_popup) {
    font-weight: bold;
    font-size: 1.5em; 
  }
</style>

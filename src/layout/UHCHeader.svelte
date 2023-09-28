<script>
  import { themes } from '../config.js';
  import { getContext } from 'svelte';
  import Icon from '@iconify/svelte';

  export let theme = getContext('theme');
  export let filled = false;
  export let center = true;
</script>

<nav
  class="parent"
  style="border-bottom-color: {themes[theme]['muted']}; {filled
    ? 'background-color: ' + themes[theme]['background'] + ';'
    : ''}"
>
  <div class="float-container">
    <div class="float-child col-wide middle" class:center>
      <a href="https://drexel.edu/uhc/">
        <div id="svg-container">
          <img
            id="my-svg"
            src="./img/uhc-primary-blue_black.svg"
            alt="Drexel Urban Health Collaborative"
          />
        </div>
      </a>
    </div>

    <div class="float-child container_container">
      <div class="container">
        <!-- <a href="https://github.com/Drexel-UHC">
        <div class="social-icon"><Icon icon="mdi:github" /></div>
      </a> -->
        <a href="https://www.facebook.com/DrexelUHC/">
          <div class="social-icon"><Icon icon="il:facebook" /></div>
        </a>
        <a href="https://twitter.com/drexeluhc">
          <div class="social-icon"><Icon icon="mdi:twitter" /></div>
        </a>
        <a href="https://www.instagram.com/drexeluhc">
          <div class="social-icon"><Icon icon="mdi:instagram" /></div>
        </a>
        <a href="https://www.youtube.com/@urbanhealthcollaborative8928">
          <div class="social-icon"><Icon icon="mdi:youtube" /></div>
        </a>
        <a
          href="https://www.linkedin.com/company/drexel-urban-health-collaborative/"
        >
          <div class="social-icon"><Icon icon="mdi:linkedin" /></div>
        </a>
      </div>
    </div>
  </div>
</nav>

<style>
  #svg-container {
    width: 200px; /* Set the desired width of the container */
    height: 50px; /* Set the desired height of the container */
  }

  #my-svg {
    width: 100%; /* Make the SVG width fill the container */
    height: 100%; /* Make the SVG height fill the container */
    object-fit: contain; /* Adjust the object-fit property as per your needs */
  }

  .parent {
    height: 80px;
  }

  nav {
    -webkit-box-sizing: border-box;
    box-sizing: border-box;
    position: relative;

    margin-bottom: -40px;
    border-bottom: 1px solid #777;
    z-index: 1;
  }
  a img:hover {
    cursor: pointer;
  }
  .container_container {
    display: flex;
    flex-direction: row;
    align-content: center;
    justify-content: space-between;
  }
  .container {
    display: flex;
    flex-direction: row;
    align-items: center;
    justify-content: space-between;
    /* border: 1px solid black; */
  }
  .social-icon {
    font-size: 1.5rem;
    padding: 0.5rem;
  }

  .float-container {
    width: 100%;
    display: flex;
    flex-direction: row;
    justify-content: space-between;
    padding-left: 5%;
    padding-right: 5%;
  }

  .float-child {
    width: min-content;
  }

  @media (max-width: 400px) {
    .parent {
      height: 120px;
    }

    .float-container {
      width: 100%;
      display: flex;
      flex-direction: column;
      justify-content: center;
      align-items: center;
      padding-left: 5%;
      padding-right: 5%;
    }

    .float-child {
      width: min-content;
    }
  }
</style>

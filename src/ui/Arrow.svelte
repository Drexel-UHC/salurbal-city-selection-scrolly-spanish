<script>
  export let color = 'black';
  export let animation = true;
  export let center = true;

  const colors = ['black', 'white'];

  color = colors.includes(color) ? color : 'black';
</script>

{#if center}
  <slot /><br />
  <img
    src="./img/scroll-down-{color}.svg"
    class="arrow"
    class:bounce={animation}
    alt=""
    aria-hidden="true"
  />
{:else}
  <img
    src="./img/scroll-down-{color}.svg"
    class="arrow left"
    class:bounce={animation}
    alt=""
    aria-hidden="true"
  /><slot />
{/if}

<style>
  .arrow {
    width: 28px;
    height: 28px;
  }
  .left {
    margin-right: 10px;
  }
  .bounce {
    -webkit-animation-duration: 1.5s;
    animation-duration: 1.5s;
    -webkit-animation-iteration-count: infinite;
    animation-iteration-count: infinite;
    -webkit-animation-name: bounce;
    animation-name: bounce;
    -webkit-animation-timing-function: ease;
    animation-timing-function: ease;
  }
  @-webkit-keyframes bounce {
    0% {
      -webkit-transform: translateY(10px);
      transform: translateY(10px);
    }
    30% {
      -webkit-transform: translateY(-10px);
      transform: translateY(-10px);
    }
    50% {
      -webkit-transform: translateY(10px);
      transform: translateY(10px);
    }
    100% {
      -webkit-transform: translateY(10px);
      transform: translateY(10px);
    }
  }
  @keyframes bounce {
    0% {
      -webkit-transform: translateY(10px);
      transform: translateY(10px);
    }
    30% {
      -webkit-transform: translateY(-10px);
      transform: translateY(-10px);
    }
    50% {
      -webkit-transform: translateY(10px);
      transform: translateY(10px);
    }
    100% {
      -webkit-transform: translateY(10px);
      transform: translateY(10px);
    }
  }
</style>

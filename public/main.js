import * as THREE from 'three';
import { OBJLoader } from 'three/addons/loaders/OBJLoader.js';
import { MTLLoader } from 'three/addons/loaders/MTLLoader.js';
// import { OrbitControls } from 'three/addons/controls/OrbitControls.js';

const loader = new THREE.TextureLoader();
const texture = await loader.loadAsync('3d/water2.JPG');
texture.wrapS = THREE.RepeatWrapping;
texture.wrapT = THREE.RepeatWrapping;

// texture.magFilter = THREE.NearestFilter;
// texture.minFilter = THREE.NearestFilter;

let width = document.documentElement.clientWidth * window.devicePixelRatio;
let height = document.documentElement.clientHeight * window.devicePixelRatio;

// init

const camera = new THREE.PerspectiveCamera(70, width / height, 1.3, 100);
const scene = new THREE.Scene();

// add fog to show perspective
const color = 0;
const near = 0.1;
const far = 10;
scene.fog = new THREE.Fog(color, near, far);

const renderer = new THREE.WebGLRenderer({ antialias: true });
//const controls = new OrbitControls(camera, renderer.domElement);
let waterShader = new THREE.ShaderMaterial({
    uniforms: {
        buffer: { value: texture },
        time: { type: 'float', value: 0.0 },
    },
    vertexShader: vertexShader(),
    fragmentShader: fragmentShader()
});

function getCameraOffset(aspect) {
    return 0.9639917695473 * aspect - 1.9753086419753;
}

renderer.setSize(width, height);
renderer.setClearColor(new THREE.Color(0x3DABFF), 0)

function vertexShader() {
    return `
    uniform float time;
    varying vec2 vUv;
    varying float h;

    void main(){
        vUv=position.xz*0.1+.5;
        vec3 c = position;
        c.y += sin(time/1200.0+position.z+position.x) * 0.04;
        h=c.y;

        vec4 modelViewPosition = modelViewMatrix * vec4(c, 1.0);
        gl_Position = projectionMatrix * modelViewPosition;
    }
  `
}
function fragmentShader() {
    return `
    precision highp float;

    uniform sampler2D buffer;
    varying vec2 vUv;
    varying float h;
    uniform float time;

    void main(){
        float value = (h)*1.3;
        vec2 movedUv = vUv;
        movedUv.y += sin(time/1000.0)/100.0;
        movedUv.x += sin(time/1000.0)/100.0;
        vec4 texel=texture2D(buffer,movedUv);
        texel.rgb += vec3(value,value,value);
        gl_FragColor=texel;
    }
    `
}
const mtlLoader = new MTLLoader().setPath('3d/');
const objLoader = new OBJLoader().setPath('3d/');

async function loadModel(name, material) {
    const materials = await mtlLoader.loadAsync(name + '.mtl');
    materials.preload();
    if (material != undefined && material != null) {
        materials.materials.Material = material;
    }
    // add transparency for bush and ship material.
    // ik this is hardcoded and all but im in a hurry to get this finished ok
    if (materials.materials.Bush != null) {
        materials.materials.Bush.transparent = true;
        materials.materials.Ship.transparent = true;
    }
    for (let m of Object.keys(materials.materials)) {
        if (materials.materials[m].map == undefined || m == "Ship") { continue }
        materials.materials[m].map.magFilter = THREE.NearestFilter;
        materials.materials[m].map.minFilter = THREE.NearestFilter;
    }
    objLoader.setMaterials(materials);

    return await objLoader.loadAsync(name + '.obj')
}

let island = await loadModel("island");
let ship;
for (let child of island.children) {
    if (child.name == "Ship") {
        ship = child;
    }
}
scene.add(island);
let water = await loadModel("water", waterShader);

water.position.y = 0.125;
water.position.x = 5.5;
water.position.z = -10.5;
scene.add(water);

globalThis.camera = camera;

// lights :>
const ambientLight = new THREE.AmbientLight(0xffffff, 3);
scene.add(ambientLight);
//const hemiLight = new THREE.HemisphereLight(0x0000ff, 0x00ff00, 0.6);
//scene.add(hemiLight);

renderer.setAnimationLoop(animate);
document.body.appendChild(renderer.domElement);

// set up default camera state
let cameraStartX = 3.890794575489123;
camera.position.set(cameraStartX + getCameraOffset(width / height), 0.9752466284680337, 3.406702477655009);

// set default camera rotation
camera.rotation.x = -0.06501676300811605;
camera.rotation.y = 0.014735025041483576;
camera.rotation.z = 0.0009593408193955247;


function animate(time) {
    waterShader.uniforms["time"].value = time;


    let relPosition = water.position;
    // PI / 16 is subtracted to make it a bit delayed compared to the water
    // to give an effect of having mass
    ship.position.y = Math.sin(time / 1200.0 + relPosition.z + relPosition.x - Math.PI / 16) * 0.04;

    //controls.update();
    renderer.render(scene, camera);
}

window.addEventListener("resize", () => {
    width = document.documentElement.clientWidth * window.devicePixelRatio;
    height = document.documentElement.clientHeight * window.devicePixelRatio;

    camera.width = width;
    camera.height = height;
    camera.aspect = width / height
    camera.updateProjectionMatrix();

    camera.position.x = cameraStartX + getCameraOffset(width / height);

    renderer.setSize(width, height);
});
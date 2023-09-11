package kmeans

import (
	"container/heap"
	"dupbackend/model"
	"dupbackend/utils"
	"fmt"
	"log"
	"math"
	"math/rand"
	"os"
	"time"
)

// 自定义大根堆
type MaxHeap []cluster

func (h MaxHeap) Len() int           { return len(h) }
func (h MaxHeap) Less(i, j int) bool { return h[i].DocCount > h[j].DocCount }
func (h MaxHeap) Swap(i, j int)      { h[i], h[j] = h[j], h[i] }

func (h *MaxHeap) Push(x interface{}) {
	*h = append(*h, x.(cluster))
}

func (h *MaxHeap) Pop() interface{} {
	old := *h
	n := len(old)
	x := old[n-1]
	*h = old[:n-1]
	return x
}

// 自定义小根堆
type MinHeap []tmpDis

func (h MinHeap) Len() int           { return len(h) }
func (h MinHeap) Less(i, j int) bool { return h[i].Dis < h[j].Dis }
func (h MinHeap) Swap(i, j int)      { h[i], h[j] = h[j], h[i] }

func (h *MinHeap) Push(x interface{}) {
	*h = append(*h, x.(tmpDis))
}

func (h *MinHeap) Pop() interface{} {
	old := *h
	n := len(old)
	x := old[n-1]
	*h = old[:n-1]
	return x
}

// 零食
type tmpDis struct {
	Dis float64
	Doc int
}

type cluster struct {
	Label       string    // 聚类标签
	DocCount    int       // 聚类文档数
	Center      []float64 // 聚类中心
	IncludeDocs []int     // 包含文档索引
	NearestDocs []int     // 距离最近5文档
}

type KMeans struct {
	K             int         // 聚类数
	InputData     [][]float64 // 输入向量
	InputDocNames []string    // 输入向量对应文档名
	Lang          string      // 聚类文档语言

	clusters []cluster // 聚类结果
}

func (k *KMeans) Fit(docNames []string) []model.DocumentCluster {
	k.InputDocNames = docNames

	// 校验输入
	if k.K > len(k.InputData) || k.K <= 0 {
		log.Fatalf("[KMeans] Error: K must in range of [0, %v], But your K is: %v.\n", len(k.InputData), k.K)
		os.Exit(0)
	}

	// 初始化选取中心点
	k.pickStartCenter()
	for _, v := range k.clusters {
		fmt.Println("[KMeans]: Initial center: ", v.Center)
		fmt.Println("[KMeans]: Initial docs: ", v.IncludeDocs)
	}

	isChanged := true
	count := 0
	for isChanged {
		log.Println("Iterator count: ", count+1)
		if count+1 > 20 {
			log.Println("Iterator count are more, please try again.")
			os.Exit(0)
		}
		count++
		// 清空簇
		for t := 0; t < k.K; t++ {
			k.clusters[t].IncludeDocs = []int{}
		}
		// fmt.Println(k.clusters)
		for i, v := range k.InputData {
			maxDistance := math.Inf(-1)
			var center int

			// 寻找簇
			for j := 0; j < k.K; j++ {
				// 余弦距离
				dis := k.getDistance(v, k.clusters[j].Center)
				if dis > maxDistance {
					maxDistance = dis
					center = j
				}
			}
			// fmt.Println("[KMeans----]: find cluster: ", center)
			// 加入簇
			k.clusters[center].IncludeDocs = append(k.clusters[center].IncludeDocs, i)
		}
		var newCenters [][]float64
		// 重新计算每个簇的中心
		for _, value := range k.clusters {
			newCenters = append(newCenters, k.reCalculateCenter(value))
		}

		// for _, v := range newCenters {
		// 	fmt.Println("[KMeans----]: new cluster center: ", v)
		// }

		// 判断类中心是否发生变化
		if k.isCenterChanged(newCenters) {
			for ii := 0; ii < k.K; ii++ {
				k.clusters[ii].Center = newCenters[ii]
			}
		} else {
			isChanged = false
		}

	}

	// for _, v := range k.clusters {
	// 	var docs []string
	// 	for _, v := range v.IncludeDocs {
	// 		docs = append(docs, k.InputDocNames[v])
	// 	}
	// 	fmt.Println("[KMeans]: final cluster docs: ", docs)
	// }

	log.Println("[KMeans]: Cluster finish.")

	// 计算各聚簇包含文档数
	log.Println("Start calculate doc count...")
	for i, v := range k.clusters {
		k.clusters[i].DocCount = len(v.IncludeDocs)
	}
	log.Println("Finish...")

	log.Println("Start calculate nearest docs of each cluster...")
	for i, cluster := range k.clusters {
		nearestH := &MinHeap{}
		heap.Init(nearestH)
		for _, v := range cluster.IncludeDocs {
			// 计算每个文档和聚簇中心的距离插入小根堆
			dis := k.getDistance(k.InputData[v], cluster.Center)
			tmp := tmpDis{
				Doc: v,
				Dis: dis,
			}
			heap.Push(nearestH, tmp)
			if nearestH.Len() > 5 {
				heap.Pop(nearestH)
			}
		}

		for nearestH.Len() > 0 {
			nearestDoc := heap.Pop(nearestH).(tmpDis)
			log.Println("[MinHeap]: ", nearestDoc)
			cluster.NearestDocs = append(cluster.NearestDocs, nearestDoc.Doc)
		}
		k.clusters[i].NearestDocs = cluster.NearestDocs
		log.Println("[cluster.NearestDocs]: ", cluster.NearestDocs)
	}
	log.Println("Finish...")

	for _, v := range k.clusters {
		fmt.Println("[KMeans]: nearest docs of each cluster: ", v.NearestDocs)
	}

	// 插入大根堆
	log.Println("Start Heap Insert...")
	h := &MaxHeap{}
	heap.Init(h)
	for _, v := range k.clusters {
		heap.Push(h, v)
	}
	log.Println("Finish...")

	var retCluster []model.DocumentCluster

	for h.Len() > 0 {
		var nearestDoc []string
		hCluster := heap.Pop(h).(cluster)
		log.Println("cluster docs are: ", hCluster.DocCount)
		for _, v := range hCluster.NearestDocs {
			nearestDoc = append(nearestDoc, k.InputDocNames[v])
		}
		docCluster := model.DocumentCluster{
			Label:       "default",
			ClusterType: k.K,
			DocCount:    hCluster.DocCount,
			NearestDoc:  fmt.Sprintf("%v", nearestDoc),
			Lang:        k.Lang,
		}
		retCluster = append(retCluster, docCluster)
	}

	return retCluster
}

// 初始化中心点
func (k *KMeans) pickStartCenter() {
	indexSet := make(map[int]bool)
	rand.Seed(time.Now().Unix())
	for len(k.clusters) < k.K {
		index := rand.Intn(len(k.InputData))
		if !indexSet[index] {
			center := cluster{
				DocCount:    1,
				Center:      k.InputData[index],
				IncludeDocs: []int{index},
			}
			k.clusters = append(k.clusters, center)
			indexSet[index] = true
		}
	}
}

// 更新中心点
func (k *KMeans) reCalculateCenter(cc cluster) []float64 {
	var newCenters []float64
	lens := len(k.InputData[0])
	for j := 0; j < lens; j++ {
		var tmp float64
		for _, v := range cc.IncludeDocs {
			// fmt.Printf("j: %v, v: %v\n", j, v)
			tmp += k.InputData[v][j]
		}
		newCenters = append(newCenters, tmp/float64(len(cc.IncludeDocs)))
	}

	return newCenters
}

// 中心点是否发生变化
func (k *KMeans) isCenterChanged(newCenters [][]float64) bool {
	for i := 0; i < len(k.clusters); i++ {
		s1 := k.calculateSum(newCenters[i])
		s2 := k.calculateSum(k.clusters[i].Center)

		// fmt.Printf("s1: %v, s2: %v\n", s1, s2)
		if s1 != s2 {
			return true
		}
	}
	return false
}

func (k *KMeans) calculateSum(arr []float64) float64 {
	var sum float64
	for _, v := range arr {
		sum += v
	}
	return sum
}

// 计算余弦距离
func (k *KMeans) getDistance(data []float64, center []float64) float64 {
	// k.InputData[i], center
	normalData := utils.NormalizeVector(data)
	normalCenter := utils.NormalizeVector(center)

	dis, _ := utils.GetCosDistance(normalData, normalCenter)

	return dis
}
